resource "aws_sqs_queue" "sqs_sample_service" {
  name                       = "sqs-sample-service"
  message_retention_seconds  = 60
  visibility_timeout_seconds = 60 # always make sure visibility timeout should be more than lambda timeout
}

resource "aws_lambda_event_source_mapping" "sqs_lambda_sample_service" {
  event_source_arn = aws_sqs_queue.sqs_sample_service.arn
  function_name    = aws_lambda_function.lambda_sample_service.arn
}

data "aws_iam_policy_document" "sqs_policy_data" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      # "sqs:*",
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      aws_sqs_queue.sqs_sample_service.arn
    ]
  }
}
resource "aws_iam_role_policy" "sqs_policy" {
  name   = "lambda-sqs-policy"
  role   = aws_iam_role.iam_for_lambda.id
  policy = data.aws_iam_policy_document.sqs_policy_data.json
}
