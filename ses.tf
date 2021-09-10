variable "email_list" {
  type    = list(string)
  default = ["vishalsg42@gmail.com"]
}
resource "aws_ses_email_identity" "email_identity" {
  for_each = toset(var.email_list)
  email    = each.value
}
