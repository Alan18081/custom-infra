#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "ascend-microservices" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = tomap({
    "Name" = var.vpc-name,
    "kubernetes.io/cluster/${var.cluster-name}" = "shared",
  })
}

resource "aws_subnet" "ascend-microservices" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.ascend-microservices.id

  tags = tomap({
    "Name" = var.vpc-name,
    "kubernetes.io/cluster/${var.cluster-name}" = "shared",
  })
}

resource "aws_internet_gateway" "ascend-microservices" {
  vpc_id = aws_vpc.ascend-microservices.id

  tags = {
    Name = var.internet-gateway-tag
  }
}

resource "aws_route_table" "ascend-microservices" {
  vpc_id = aws_vpc.ascend-microservices.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ascend-microservices.id
  }
}

resource "aws_route_table_association" "ascend-microservices" {
  count = 2

  subnet_id      = aws_subnet.ascend-microservices.*.id[count.index]
  route_table_id = aws_route_table.ascend-microservices.id
}
