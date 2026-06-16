terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# -------------------------------------------------------
# Deploy one CloudWatch Log Group per Lambda function.
# Created first so logs are captured from the very first
# Lambda invocation and retention is enforced from day 1.
# -------------------------------------------------------
module "cloudwatch" {
  source   = "./modules/cloudwatch"
  for_each = var.lambda_functions

  function_name      = each.key
  log_retention_days = each.value.log_retention_days

  tags = merge(var.common_tags, {
    Function = each.key
  })
}

# -------------------------------------------------------
# Deploy one Lambda function per entry in lambda_functions.
# Each function depends on its CloudWatch log group so the
# group always exists before the function starts running.
# -------------------------------------------------------
module "lambda" {
  source   = "./modules/lambda"
  for_each = var.lambda_functions

  function_name         = each.key
  ecr_image_uri         = each.value.ecr_image_uri
  memory_size           = each.value.memory_size
  timeout               = each.value.timeout
  architecture          = each.value.architecture
  environment_variables = each.value.environment_variables

  tags = merge(var.common_tags, {
    Function = each.key
  })

  # Ensure the log group exists before the Lambda function is created
  depends_on = [module.cloudwatch]
}

# -------------------------------------------------------
# Deploy one API Gateway per Lambda function.
# Each API Gateway is linked to its corresponding Lambda.
# -------------------------------------------------------
module "api_gateway" {
  source   = "./modules/api_gateway"
  for_each = var.lambda_functions

  api_name             = "${each.key}-http-api"
  lambda_invoke_arn    = module.lambda[each.key].invoke_arn
  lambda_function_name = module.lambda[each.key].function_name

  tags = merge(var.common_tags, {
    Function = each.key
  })
}
