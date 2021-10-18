resource "aws_db_subnet_group" "balder_db" {
  name = ""
  subnet_ids = [aws_subnet.balder_public_1.id, aws_subnet.balder_public_2.id]
}

resource "aws_db_instance" "audit" {
  instance_class = "db.t3.small"
  engine = "sqlserver-ex"
  username = var.admin_db_username
  password = var.admin_db_password
  publicly_accessible = true
  db_subnet_group_name = aws_db_subnet_group.ascend-microservices.name
  vpc_security_group_ids = [aws_security_group.audit-rds.id]
  allocated_storage = 20

  maintenance_window = "Sun:09:00-Sun:09:30"
  backup_retention_period = 0
}

resource "aws_db_snapshot" "audit-snapshot" {
  db_instance_identifier = aws_db_instance.audit.id
  db_snapshot_identifier = "audit-snapshot"
}