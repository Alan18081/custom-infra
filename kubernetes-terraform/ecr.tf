resource "aws_ecr_repository" "audit-service-ecr" {
  name = var.ecr-name
}