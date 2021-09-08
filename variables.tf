variable "aws_profile" {
  type = string
  description = "AWS profile to authorise the resource to be created"
}

variable "aws_region" {
  type = string
  description = "AWS region in which regions will be provisioned"
}

# variable "environment" {
#   type = map(string)
#   default = {
#       "dev": "dev"
#       "stage": "stage"
#       "prod": "prod"
#   }
#   description = "Name of the environment to be selected"
# }

variable "client_name" {
  type = string
  default = "demo"
  description = "Name of the client"
}