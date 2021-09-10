resource "aws_api_gateway_rest_api" "root" {
  name        = "sample-api"
  description = "Triggers the  SQS "
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "f1" {
  parent_id   = aws_api_gateway_rest_api.root.root_resource_id
  path_part   = "f1"
  rest_api_id = aws_api_gateway_rest_api.root.id
  depends_on = [
    aws_api_gateway_rest_api.root
  ]
}


resource "aws_api_gateway_resource" "f2" {
  parent_id   = aws_api_gateway_resource.f1.id
  path_part   = "f2"
  rest_api_id = aws_api_gateway_rest_api.root.id

  depends_on = [
    aws_api_gateway_resource.f1,
  ]
}

# resource "aws_api_gateway_method" "sample_method_options" {
#   http_method = "OPTIONS"
#   authorization = "NONE"
#   resource_id = aws_api_gateway_resource.f2.id
#   rest_api_id = aws_api_gateway_rest_api.root.id
# }

resource "aws_api_gateway_method" "sample_method_post" {
  http_method   = "POST"
  authorization = "NONE"
  resource_id   = aws_api_gateway_resource.f2.id
  rest_api_id   = aws_api_gateway_rest_api.root.id
  depends_on = [
    aws_api_gateway_resource.f2,
  ]
}

# resource "aws_api_gateway_resource" "f2" {
#   parent_id   = aws_api_gateway_rest_api.
#   path_part   = "f2"
#   rest_api_id = aws_api_gateway_rest_api.root.id
# }

resource "aws_iam_role" "api-role" {
  name = "api-role"
  # assume_role_policy = data.aws_iam_policy_document.lambda_policy_document.json
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "api-policy" {
  name = "api-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "sqs:GetQueueUrl",
          "sqs:ChangeMessageVisibility",
          "sqs:ListDeadLetterSourceQueues",
          "sqs:SendMessageBatch",
          "sqs:PurgeQueue",
          "sqs:ReceiveMessage",
          "sqs:SendMessage",
          "sqs:GetQueueAttributes",
          "sqs:CreateQueue",
          "sqs:ListQueueTags",
          "sqs:ChangeMessageVisibilityBatch",
          "sqs:SetQueueAttributes"
        ],
        "Resource" : "${aws_sqs_queue.sqs_sample_service.arn}"
      },
      {
        "Effect" : "Allow",
        "Action" : "sqs:ListQueues",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_policy_attachment" {
  role       = aws_iam_role.api-role.name
  policy_arn = aws_iam_policy.api-policy.arn

  depends_on = [
    aws_iam_role.api-role,
    aws_iam_policy.api-policy
  ]
}


resource "aws_api_gateway_integration" "sqs_integration" {
  http_method             = aws_api_gateway_method.sample_method_post.http_method
  resource_id             = aws_api_gateway_resource.f2.id
  rest_api_id             = aws_api_gateway_rest_api.root.id
  type                    = "AWS"
  integration_http_method = "POST"
  credentials             = aws_iam_role.api-role.arn
  passthrough_behavior    = "NEVER"

  # type = "MOCK"
  # credentials             = aws_sqs_queue.sqs_sample_service.arn

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }
  request_templates = {
    "application/json" = "Action=SendMessage&MessageBody=$input.body"
  }
  uri = "arn:aws:apigateway:${var.aws_region}:sqs:path/${aws_sqs_queue.sqs_sample_service.name}"


  depends_on = [
    aws_api_gateway_method.sample_method_post,
    aws_iam_role.api-role,
  ]

}

resource "aws_api_gateway_method_response" "method_200_response" {
  rest_api_id = aws_api_gateway_rest_api.root.id
  resource_id = aws_api_gateway_resource.f2.id
  http_method = aws_api_gateway_method.sample_method_post.http_method
  status_code = 200

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [
    aws_api_gateway_integration.sqs_integration
  ]
}

resource "aws_api_gateway_integration_response" "integration_200_response" {
  rest_api_id         = aws_api_gateway_rest_api.root.id
  resource_id         = aws_api_gateway_resource.f2.id
  http_method         = aws_api_gateway_method.sample_method_post.http_method
  status_code         = aws_api_gateway_method_response.method_200_response.status_code
  selection_pattern   = "^2[0-9][0-9]" // regex pattern for any 200 message that comes back from SQS
  response_parameters = {}

  depends_on = [
    aws_api_gateway_method_response.method_200_response
  ]
}

# Deployment


resource "aws_api_gateway_deployment" "sample_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.root.id
  depends_on = [
    aws_api_gateway_method.sample_method_post,
    aws_api_gateway_integration_response.integration_200_response,
  ]
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.sample_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.root.id
  stage_name    = "prod"
  depends_on = [
    aws_api_gateway_method.sample_method_post,
    aws_api_gateway_integration_response.integration_200_response,
  ]
}
