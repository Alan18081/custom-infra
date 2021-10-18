variable "ecs_ami_image" {
  default = "ami-09db5b31ad3cd145d"
  type = string
}

variable "ecs_ec2_instance_type" {
  default = "t2.micro"
  type = string
}

variable "admin_db_username" {
  default = "admin"
  type = string
}

variable "admin_db_password" {
  default = "password"
  type = string
}