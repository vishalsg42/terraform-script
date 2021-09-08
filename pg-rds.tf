
variable "rds_allocated_storage" {
  type    = number
  default = 20
}

variable "rds_instance_type" {
  type    = string
  default = "db.t3.micro"
}

variable "rds_apply_immediately" {
  type    = bool
  default = true
}

variable "rds_publicly_accessible" {
  type    = bool
  default = false
}

variable "rds_username" {
  type      = string
  sensitive = true
}

variable "rds_password" {
  type      = string
  sensitive = true
}

variable "rds_database_name" {
  type      = string
  sensitive = true
}

variable "rds_port" {
  type = number
}

variable "rds_skip_final_snapshot" {
  type    = bool
  default = true
}
variable "rds_security_group_name" {
  type    = string
  default = "rds_security_group"
}

locals {
  rds_indentifier = var.client_name
}


resource "aws_db_instance" "rds_pg" {
  allocated_storage      = var.rds_allocated_storage
  engine                 = "postgres"
  engine_version         = "13.3"
  instance_class         = var.rds_instance_type
  identifier             = local.rds_indentifier
  name                   = var.rds_database_name
  username               = var.rds_username
  password               = var.rds_password
  skip_final_snapshot    = var.rds_skip_final_snapshot
  apply_immediately      = var.rds_apply_immediately
  publicly_accessible    = var.rds_publicly_accessible
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
}

resource "aws_security_group" "rds_security_group" {
  description = "RDS Security to handle the networking allow/deny"
  name        = var.rds_security_group_name


  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      description      = "Allow everyone to access database"
      from_port        = 5432
      to_port          = 5432
      protocol         = "tcp"
      self             = false
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
    }
  ]

  tags = {
    "Name" = local.rds_indentifier
  }
}
