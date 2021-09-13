resource "aws_dynamodb_table" "aws_infra_table" {
  name         = "aws_infra_table"
  # billing_mode = "PROVISIONED" # for predictable traffic
  billing_mode = "PAY_PER_REQUEST" # for unpredictable traffic

  hash_key = "message_id"

  attribute {
    name = "message_id"
    type = "S"
  }

 # attribute {
 #   name = "name"
 #   type = "S"
 # }

 # attribute {
 #   name = "email"
 #   type = "S"
 # }

 # attribute {
 #   name = "message"
 #   type = "S"
 # }

 # attribute {
 #   name = "body"
 #   type = "S"
 # }

}

output "dynamo_db_arn" {
  value = aws_dynamodb_table.aws_infra_table.arn
}

output "dynamo_table_name" {
  value = aws_dynamodb_table.aws_infra_table.id
}