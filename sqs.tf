resource "aws_sqs_queue" "sqs_sample_service" {
  name                      = "sqs-sample-service"
  message_retention_seconds = 60
  visibility_timeout_seconds = 60 # always make sure visibility timeout should be more than lambda timeout
}

resource "aws_lambda_event_source_mapping" "sqs_lambda_sample_service" {
  event_source_arn = aws_sqs_queue.sqs_sample_service.arn
  function_name    = aws_lambda_function.lambda_sample_service.arn
}
