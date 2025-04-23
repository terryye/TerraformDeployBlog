resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = var.private_subnet_ids
}

resource "aws_db_instance" "webapp_rds" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0" # Use the latest stable version
  instance_class         = "db.t3.micro"
  db_name                = "ghost"
  username               = "dbuser"
  password               = "securepassword" # Replace with a secure password
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [var.db_security_group_id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  parameter_group_name   = "default.mysql8.0"

}


variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "db_security_group_id" {
  type = string
}

variable "ec2_security_group_id" {
  type = string
}

output "db_instance_address" {
  value = aws_db_instance.webapp_rds.address
}

output "db_instance_port" {
  value = aws_db_instance.webapp_rds.port
}

output "db_username" {
  value = aws_db_instance.webapp_rds.username
}

output "db_password" {
  value = aws_db_instance.webapp_rds.password
  sensitive = true
}

output "db_name" {
  value = aws_db_instance.webapp_rds.db_name
}