variable "aws-region" {
  default = "us-east-2"
}

variable "cluster-name" {
  default = "ascend-microservices-cluster"
  type    = string
}

variable "ecr-name" {
  default = "audit"
  type = string
}

variable "vpc-name" {
  default = "ascend-microservices"
  type    = string
}

variable "internet-gateway-tag" {
  default = "ascend-microservices"
}

variable "database-username" {
  default = "admin"
  type = string
}

variable "database-password" {
  default = "Dentrix1"
  type = string
}

variable "aws-account-id" {
  default = 660083024328
  type = number
}

variable "aws-frontend-s3-bucket" {
  default = "vue-builds"
  type = string
}