# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

# Attach basic execution role (includes CloudWatch Logs permissions)
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Inline policy to allow writing to the specific CloudWatch log group
resource "aws_iam_role_policy" "lambda_cloudwatch_policy" {
  name = "${var.function_name}-cloudwatch-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:log-group:/aws/lambda/${var.function_name}:*"
      }
    ]
  })
}

# Lambda Function
# The CloudWatch log group is created separately (see module "cloudwatch" in main.tf)
# and its name is passed in via var.log_group_name so that the log group always
# exists before the function starts emitting logs.
resource "aws_lambda_function" "this" {
  function_name = var.function_name

  package_type = "Image"
  image_uri    = var.ecr_image_uri

  role = aws_iam_role.lambda_role.arn

  memory_size = var.memory_size
  timeout     = var.timeout

  architectures = [var.architecture]

  environment {
    variables = var.environment_variables
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic
  ]

  tags = var.tags
}
