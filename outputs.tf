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
