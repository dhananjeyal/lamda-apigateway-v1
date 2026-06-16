variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "ecr_image_uri" {
  description = "ECR image URI for the Lambda function container image"
  type        = string
}

variable "memory_size" {
  description = "Amount of memory (MB) allocated to the Lambda function"
  type        = number
  default     = 3008
}

variable "timeout" {
  description = "Timeout in seconds for the Lambda function"
  type        = number
  default     = 900
}

variable "architecture" {
  description = "Instruction set architecture for the Lambda function (x86_64 or arm64)"
  type        = string
  default     = "x86_64"
}

variable "environment_variables" {
  description = "Map of environment variables to pass to the Lambda function"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to all resources in this module"
  type        = map(string)
  default     = {}
}
