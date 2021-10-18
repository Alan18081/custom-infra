resource "aws_security_group" "balder_ecs_sg" {
  vpc_id = aws_vpc.balder_vpc.id

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    protocol = "tcp"
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "tcp"
    to_port = 65535
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "balder_rds_sg" {
  vpc_id = aws_vpc.balder_vpc.id

  ingress {
    from_port = 1433
    protocol = "tcp"
    to_port = 1433
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.balder_ecs_sg.id]
  }

  egress {
    from_port = 0
    protocol = ""
    to_port = 65535
    cidr_blocks = ["0.0.0.0/0"]
  }
}