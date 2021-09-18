
locals {
  formatted_cognito_domain_name = lower(random_string.cognito_domain_prefix.id)
}

resource "random_string" "cognito_domain_prefix" {
  length  = 8
  lower   = true
  upper   = false
  number  = false
  special = false
}

resource "aws_cognito_user_pool" "user_pool" {
  name = "user_pool"

  # sms_authentication_message = "Your code is {####}"

  #password_policy {
  #  minimum_length = 6
  #}
}

resource "aws_cognito_user_pool_domain" "cognito_domain" {
  # domain = "https://${local.formatted_cognito_domain_name}.auth.${var.aws_region}.amazoncognito.com"
  domain       = local.formatted_cognito_domain_name
  user_pool_id = aws_cognito_user_pool.user_pool.id
}

resource "aws_cognito_resource_server" "user_pool_resource" {
  identifier = "messages"
  name       = "test-resource"

  user_pool_id = aws_cognito_user_pool.user_pool.id

  scope {
    scope_name        = "read"
    scope_description = "This scope is for fetching the test api"
  }
  scope {
    scope_name        = "write"
    scope_description = "This scope is for writing the test api"
  }
}


resource "aws_cognito_user_pool_client" "test_api_client" {
  name                                 = "test-client"
  user_pool_id                         = aws_cognito_user_pool.user_pool.id
  generate_secret                      = true
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows = [
    "client_credentials",
  ]
  allowed_oauth_scopes = aws_cognito_resource_server.user_pool_resource.scope_identifiers
  # allowed_oauth_scopes =  aws_cognito_resource_server.
  prevent_user_existence_errors = "ENABLED"
  # aws_cognito_user_pool_domain.cognito_domain.
  supported_identity_providers = [
    "COGNITO",
  ]
}

output "cognito_client_id" {
  value = aws_cognito_user_pool_client.test_api_client.id
}

output "cognito_client_secret" {
  value     = aws_cognito_user_pool_client.test_api_client.client_secret
  sensitive = true
}

output "cognito_token_url" {
  value = "https://${aws_cognito_user_pool_domain.cognito_domain.domain}.auth.ap-south-1.amazoncognito.com/oauth2/token"
}