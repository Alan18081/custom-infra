resource "aws_efs_file_system" "audit_files_system" {
  creation_token = "audit"

  tags = {
    Name = "audit"
  }
}

resource "aws_security_group" "ascend_efs_mount_target" {
  name = "ascend_nodes_mount_target_1"
  vpc_id = aws_vpc.ascend-microservices.id
  ingress {
    from_port = 2049
    protocol = "tcp"
    to_port = 2049
    cidr_blocks = [aws_vpc.ascend-microservices.cidr_block]
  }
}
//
resource "aws_efs_mount_target" "ascend_nodes_mount_target_1" {
  file_system_id = aws_efs_file_system.audit_files_system.id
  subnet_id = aws_subnet.ascend-microservices[0].id
  security_groups = [aws_security_group.ascend_efs_mount_target.id]
}

resource "aws_efs_mount_target" "ascend_node_mount_target_2" {
  file_system_id = aws_efs_file_system.audit_files_system.id
  subnet_id = aws_subnet.ascend-microservices[1].id
  security_groups = [aws_security_group.ascend_efs_mount_target.id]
}