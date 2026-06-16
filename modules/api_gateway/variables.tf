variable "api_name" {
  description = "Name of the HTTP API Gateway"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "Invoke ARN of the Lambda function to integrate with"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function (used for permission resource)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources in this module"
  type        = map(string)
  default     = {}
}
