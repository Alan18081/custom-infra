resource "aws_vpc" "balder_vpc" {
  cidr_block = "10.0.0.0/22"
}

resource "aws_internet_gateway" "balder_internet_gateway" {
  vpc_id = aws_vpc.balder_vpc.id
}

resource "aws_subnet" "balder_public_1" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.balder_vpc.id
  availability_zone = "us-east-2a"
}

resource "aws_subnet" "balder_public_2" {
  cidr_block = "10.0.2.0/24"
  vpc_id = aws_vpc.balder_vpc.id
  availability_zone = "us-east-2b"
}

resource "aws_route_table" "balder_public" {
  vpc_id = aws_vpc.balder_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.balder_internet_gateway.id
  }
}

resource "aws_route_table_association" "balder_routes" {
  route_table_id = aws_route_table.balder_public.id
  subnet_id = aws_subnet.balder_public_1.id
}