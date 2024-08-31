output "api_endpoint" {
  description = "The endpoint of the API Gateway."
  value       = "${aws_api_gateway_deployment.api_deployment.invoke_url}"
}

output "cloudfront_distribution_domain_name" {
  value       = aws_cloudfront_distribution.api_distribution.domain_name
  description = "The domain name of the CloudFront distribution"
}