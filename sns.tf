resource "aws_sns_topic" "sns_typicode" {
  name = "sns-typicode"
}

resource "aws_sns_topic_subscription" "sns_typicode_subscription" {
  topic_arn              = aws_sns_topic.sns_typicode.arn
  protocol               = "https"
  endpoint               = "https://jsonplaceholder.typicode.com/"
}
