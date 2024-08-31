provider "aws" {
  region = var.region
}

# S3バケットの作成 (Terraform State)
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.s3_tf_state_bucket_name
  lifecycle {
    prevent_destroy = true
  }
}

# S3バケットバージョニング有効化
resource "aws_s3_bucket_versioning" "versioning_enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3バケットの暗号化設定
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3バケットのパブリックアクセスブロック
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3バケットの作成 (Jeweler Storage)
resource "aws_s3_bucket" "jeweler_kizuku" {
  bucket = var.s3_jeweler_bucket_name
  # 他の設定
}

# S3バケットのウェブサイト設定
resource "aws_s3_bucket_website_configuration" "static_site_bucket" {
  bucket = aws_s3_bucket.jeweler_kizuku.bucket
  index_document {
    suffix = "index.html"
  }
  depends_on = [aws_s3_bucket.jeweler_kizuku]
}

# Lambda用のIAMロール作成
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Lambda関数の作成
resource "aws_lambda_function" "lambda_function" {
  filename         = "lambda.zip"  # ビルド済みのLambda関数ZIP
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_role.arn
  handler          = var.lambda_handler
  runtime          = var.lambda_runtime
  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket_website_configuration.static_site_bucket.bucket
    }
  }
}

# API Gatewayの設定
resource "aws_api_gateway_rest_api" "api" {
  name = "DynamicContentAPI"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "proxy_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function.invoke_arn
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on  = [aws_api_gateway_integration.proxy_integration]
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# CloudFrontディストリビューションの作成
resource "aws_cloudfront_distribution" "api_distribution" {
  origin {
    domain_name = "${aws_api_gateway_rest_api.api.id}.execute-api.${var.region}.amazonaws.com"
    origin_id   = "APIGatewayOrigin-${aws_api_gateway_rest_api.api.id}" 

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = ""

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id =  "APIGatewayOrigin-${aws_api_gateway_rest_api.api.id}" 

    forwarded_values {
      query_string = true
      headers      = ["Host"]

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = var.cloudfront_min_ttl
    default_ttl            = var.cloudfront_default_ttl
    max_ttl                = var.cloudfront_max_ttl
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = var.cloudfront_distribution_name
  }
}

# Outputs
output "cloudfront_distribution_domain_name" {
  value       = aws_cloudfront_distribution.api_distribution.domain_name
  description = "The domain name of the CloudFront distribution"
}