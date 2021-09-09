
variable "lambda_function_name" {
  type    = string
  default = "sample-services-sean"
}

variable "lambda_source_bucket" {
  type = string
}

locals {
  cloudwatch_config = {
    name              = "/aws/lambda/${var.lambda_function_name}"
    retention_in_days = 14
  }

}

# for lambda logs
resource "aws_cloudwatch_log_group" "lambda_sample_logs" {
  name              = local.cloudwatch_config.name
  retention_in_days = local.cloudwatch_config.retention_in_days
}

data "archive_file" "lambda_source_code" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-source"
  output_path = "${path.module}/lambda-source.zip"
}

# for creating s3 bucket
resource "aws_s3_bucket" "lambda_source_bucket" {
  bucket = var.lambda_source_bucket
}

# for creating s3 object
resource "aws_s3_bucket_object" "lambda_source_code_object" {
  # bucket = 
  key    = "hello-world.zip"
  bucket = aws_s3_bucket.lambda_source_bucket.id
  source = data.archive_file.lambda_source_code.output_path
  etag   = filemd5(data.archive_file.lambda_source_code.output_path)
}

# for creating policy
data "aws_iam_policy_document" "lambda_policy_document" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      aws_lambda_function.lambda_sample_service.arn
    ]
  }
}

# Generating iam role for lambda
resource "aws_iam_role" "iam_for_lambda" {
  name = "lambda-role"
  # assume_role_policy = data.aws_iam_policy_document.lambda_policy_document.json
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "lambda_assume_role" {
  name   = "lambda-sqs-policy"
  role   = aws_iam_role.iam_for_lambda.id
  policy = data.aws_iam_policy_document.lambda_policy_document.json
}
# Provisiong the lambda 
resource "aws_lambda_function" "lambda_sample_service" {
  function_name = var.lambda_function_name
  handler       = "index.handler"
  runtime       = "nodejs12.x"
  role          = aws_iam_role.iam_for_lambda.arn

  s3_bucket = aws_s3_bucket.lambda_source_bucket.id
  s3_key    = aws_s3_bucket_object.lambda_source_code_object.key

  source_code_hash = data.archive_file.lambda_source_code.output_base64sha256
  timeout          = 60

  environment {
    variables = {
      PG_USER     = aws_db_instance.rds_pg.username
      PG_HOST     = aws_db_instance.rds_pg.address
      PG_DATABASE = aws_db_instance.rds_pg.name
      PG_PASSWORD = var.rds_password
      PG_PORT     = aws_db_instance.rds_pg.port
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda_sample_logs
  ]
}
