variable "region" {
  description = "AWS Region"
  default     = "us-west-2"
}

variable "s3_tf_state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  default     = "tf-state-jeweler"
}

variable "s3_jeweler_bucket_name" {
  description = "Name of the S3 bucket for Jeweler storage"
  default     = "jeweler-storage"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  default     = "LambdaFunctionForAPIGateway"
}

variable "lambda_handler" {
  description = "Lambda function handler"
  default     = "index.handler"
}

variable "lambda_runtime" {
  description = "Lambda function runtime"
  default     = "nodejs18.x"
}

variable "cloudfront_certificate_arn" {
  description = "ARN of the ACM certificate for CloudFront"
  default     = "arn:aws:acm:us-east-1:366344796855:certificate/92397525-3fdf-4904-a2bf-5026f22c2967"
}

variable "cloudfront_distribution_name" {
  description = "Name tag for CloudFront distribution"
  default     = "APIWithCloudFront"
}

variable "cloudfront_min_ttl" {
  description = "Minimum TTL for CloudFront cache"
  default     = 0
}

variable "cloudfront_default_ttl" {
  description = "Default TTL for CloudFront cache"
  default     = 3600
}

variable "cloudfront_max_ttl" {
  description = "Maximum TTL for CloudFront cache"
  default     = 86400
}