# -------------------------------------------------------
# Outputs for all deployed Lambda functions
# -------------------------------------------------------
output "lambda_function_names" {
  description = "Names of all deployed Lambda functions"
  value       = { for k, v in module.lambda : k => v.function_name }
}

output "lambda_function_arns" {
  description = "ARNs of all deployed Lambda functions"
  value       = { for k, v in module.lambda : k => v.function_arn }
}

# -------------------------------------------------------
# Outputs for all deployed CloudWatch Log Groups
# (sourced from the standalone cloudwatch module)
# -------------------------------------------------------
output "lambda_log_group_names" {
  description = "CloudWatch log group names for all Lambda functions"
  value       = { for k, v in module.cloudwatch : k => v.log_group_name }
}

output "lambda_log_group_arns" {
  description = "CloudWatch log group ARNs for all Lambda functions"
  value       = { for k, v in module.cloudwatch : k => v.log_group_arn }
}

# -------------------------------------------------------
# Outputs for all deployed API Gateways
# -------------------------------------------------------
output "api_gateway_endpoints" {
  description = "Endpoint URLs for all deployed API Gateways"
  value       = { for k, v in module.api_gateway : k => v.api_endpoint }
}

output "api_gateway_ids" {
  description = "IDs of all deployed API Gateways"
  value       = { for k, v in module.api_gateway : k => v.api_id }
}

# -------------------------------------------------------
# Custom domain outputs (only populated when domain_name
# is set for a given Lambda function entry)
# -------------------------------------------------------
output "api_gateway_custom_domains" {
  description = "Custom domain names configured for each API Gateway (empty string if not set)"
  value       = { for k, v in module.api_gateway : k => v.custom_domain_name }
}

output "api_gateway_custom_domain_targets" {
  description = "DNS target (CNAME value) for each API Gateway custom domain. Point your DNS record here."
  value       = { for k, v in module.api_gateway : k => v.custom_domain_target }
}

output "api_gateway_custom_domain_hosted_zone_ids" {
  description = "Route 53 hosted zone IDs for each API Gateway regional endpoint (for alias records)"
  value       = { for k, v in module.api_gateway : k => v.custom_domain_hosted_zone_id }
}
