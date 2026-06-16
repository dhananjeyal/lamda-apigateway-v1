variable "function_name" {
  description = "Name of the Lambda function (used to name the log group)"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain Lambda logs in CloudWatch"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Tags to apply to the CloudWatch log group"
  type        = map(string)
  default     = {}
}
