
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

data "aws_iam_policy_document" "cloudwatch_lambda_document" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "logs:GetLogEvents",
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:DescribeLogStreams",
      "logs:PutRetentionPolicy",
      "cloudwatch:*"
    ]
    resources = [
      "*"
    ]
  }

}

data "aws_iam_policy_document" "dynamodb_lambda_document" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:BatchWriteItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem"
    ]
    resources = [
      aws_dynamodb_table.aws_infra_table.arn
    ]
  }
}

data "aws_iam_policy_document" "ses_lambda_document" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "ses:SendRawEmail",
    ]
    resources = [
      "arn:aws:ses:*:*:identity/*"
    ]
  }
}

data "aws_iam_policy_document" "s3_lambda_document" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]
    resources = [
      aws_s3_bucket.upload_bucket_name.arn,
      "${aws_s3_bucket.upload_bucket_name.arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "sns_lambda_document" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      # aws_s3_bucket.upload_bucket_name.arn,
      aws_sns_topic.sns_typicode.arn
    ]
  }
}


# Generating iam role for lambda
resource "aws_iam_role" "iam_for_lambda" {
  name = "lambda-role"
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

resource "aws_iam_role_policy" "sqs_access_policy" {
  name   = "sqs_access_policy"
  role   = aws_iam_role.iam_for_lambda.id
  policy = data.aws_iam_policy_document.lambda_policy_document.json
}

resource "aws_iam_role_policy" "cloudwatch_logs_policy" {
  name   = "cloudwatch_logs_policy"
  role   = aws_iam_role.iam_for_lambda.id
  policy = data.aws_iam_policy_document.cloudwatch_lambda_document.json
}
resource "aws_iam_role_policy" "dynamodb_access_policy" {
  name   = "dynamodb_write_policy"
  role   = aws_iam_role.iam_for_lambda.id
  policy = data.aws_iam_policy_document.dynamodb_lambda_document.json
}

resource "aws_iam_role_policy" "ses_access_policy" {
  name   = "ses_access_policy"
  role   = aws_iam_role.iam_for_lambda.id
  policy = data.aws_iam_policy_document.ses_lambda_document.json
}

resource "aws_iam_role_policy" "s3_access_policy" {
  name   = "s3_access_policy"
  role   = aws_iam_role.iam_for_lambda.id
  policy = data.aws_iam_policy_document.s3_lambda_document.json
}

resource "aws_iam_role_policy" "sns_access_policy" {
  name   = "sns_access_policy"
  role   = aws_iam_role.iam_for_lambda.id
  policy = data.aws_iam_policy_document.sns_lambda_document.json
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
      PG_USER          = aws_db_instance.rds_pg.username
      PG_HOST          = aws_db_instance.rds_pg.address
      PG_DATABASE      = aws_db_instance.rds_pg.name
      PG_PASSWORD      = var.rds_password
      PG_PORT          = aws_db_instance.rds_pg.port
      BUCKET_NAME      = aws_s3_bucket.upload_bucket_name.id
      MESSAGE_SQS_URL  = aws_sqs_queue.sqs_sample_service.url
      SNS_TYPICODE_ARN = aws_sns_topic.sns_typicode.arn
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda_sample_logs
  ]
}

output "cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.lambda_sample_logs.arn
}