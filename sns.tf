resource "aws_sns_topic" "sns_typicode" {
  name = "sns-typicode"
}

resource "aws_sns_topic_subscription" "sns_typicode_subscription" {
  topic_arn              = aws_sns_topic.sns_typicode.arn
  protocol               = "https"
  endpoint               = "https://jsonplaceholder.typicode.com/"
}

output "typicode_sns_arn" {
  value = aws_sns_topic.sns_typicode.arn
}

output "typicode_sns_confirmation" {
  value = aws_sns_topic_subscription.sns_typicode_subscription.pending_confirmation
}
