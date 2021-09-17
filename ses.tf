variable "email_list" {
  type    = list(string)
}
resource "aws_ses_email_identity" "email_identity" {
  for_each = toset(var.email_list)
  email    = each.value
}
