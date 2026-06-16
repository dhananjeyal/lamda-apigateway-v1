variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

# -------------------------------------------------------
# Lambda functions configuration map.
# Key   = function name (also used as the API Gateway name prefix)
# Value = object with required and optional settings
# -------------------------------------------------------
variable "lambda_functions" {
  description = <<EOT
Map of Lambda functions to deploy. Each key is the function name.
Each value supports:
  - ecr_image_uri        (required) : ECR image URI for the container image
  - memory_size          (optional) : Memory in MB (default: 3008)
  - timeout              (optional) : Timeout in seconds (default: 900)
  - architecture         (optional) : x86_64 or arm64 (default: x86_64)
  - environment_variables(optional) : Map of env vars (default: {})
  - log_retention_days   (optional) : CloudWatch log retention days (default: 14)
EOT
  type = map(object({
    ecr_image_uri         = string
    memory_size           = optional(number, 3008)
    timeout               = optional(number, 900)
    architecture          = optional(string, "x86_64")
    environment_variables = optional(map(string), {})
    log_retention_days    = optional(number, 14)
  }))
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    ManagedBy   = "Terraform"
    Environment = "production"
  }
}
