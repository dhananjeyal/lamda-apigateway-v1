# HTTP API Gateway
resource "aws_apigatewayv2_api" "this" {
  name          = var.api_name
  protocol_type = "HTTP"

  tags = var.tags
}

# Lambda Integration
resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_invoke_arn
  payload_format_version = "2.0"
}

# Catch-all proxy route
resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# Root route
resource "aws_apigatewayv2_route" "root" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /"

  target = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# Default stage with auto-deploy
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true

  tags = var.tags
}

# Permission for API Gateway to invoke Lambda
resource "aws_lambda_permission" "apigateway" {
  statement_id  = "AllowExecutionFromAPIGateway-${var.api_name}"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}

# -------------------------------------------------------
# Custom Domain Name (optional)
# Only created when var.domain_name is non-empty.
# -------------------------------------------------------
resource "aws_apigatewayv2_domain_name" "this" {
  count       = var.domain_name != "" ? 1 : 0
  domain_name = var.domain_name

  domain_name_configuration {
    certificate_arn = var.acm_certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  tags = var.tags
}

# Map the custom domain to the $default stage
resource "aws_apigatewayv2_api_mapping" "this" {
  count       = var.domain_name != "" ? 1 : 0
  api_id      = aws_apigatewayv2_api.this.id
  domain_name = aws_apigatewayv2_domain_name.this[0].id
  stage       = aws_apigatewayv2_stage.default.id
}
