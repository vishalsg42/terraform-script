variable "upload_bucket_name" {
  type = string
}

resource "random_id" "bucket_postfix" {
  keepers = {
    # Generate a new id each time we switch to a new AMI id
    bucket_name = "${var.upload_bucket_name}"
  }

  byte_length = 8
}

locals {
  formatted_bucket_name = lower(random_id.bucket_postfix.id)
}

resource "aws_s3_bucket" "upload_bucket_name" {
  bucket = "${local.formatted_bucket_name}-${var.aws_region}"
}

output "upload_bucket_name" {
  value =  local.formatted_bucket_name
}
