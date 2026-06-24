output "api_id" {
  description = "ID of the API Gateway"
  value       = aws_apigatewayv2_api.this.id
}

output "api_endpoint" {
  description = "Endpoint URL of the API Gateway"
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_apigatewayv2_api.this.execution_arn
}

output "custom_domain_name" {
  description = "The custom domain name configured for the API Gateway (empty if not set)"
  value       = var.domain_name != "" ? aws_apigatewayv2_domain_name.this[0].domain_name : ""
}

output "custom_domain_target" {
  description = "The API Gateway domain name target to use in your DNS CNAME/alias record"
  value       = var.domain_name != "" ? aws_apigatewayv2_domain_name.this[0].domain_name_configuration[0].target_domain_name : ""
}

output "custom_domain_hosted_zone_id" {
  description = "The Route 53 hosted zone ID of the API Gateway regional endpoint (for alias records)"
  value       = var.domain_name != "" ? aws_apigatewayv2_domain_name.this[0].domain_name_configuration[0].hosted_zone_id : ""
}
