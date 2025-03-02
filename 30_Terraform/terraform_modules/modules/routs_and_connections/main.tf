resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc
  tags = {
    Name = "Internet Gateway"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "Nat elastic IP"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  subnet_id = var.public_subnet_id.id
  allocation_id = aws_eip.nat_eip.allocation_id
  tags = {
    Name = "Nat Gatewway"
  }
}

resource "aws_security_group" "my_sg" {
  vpc_id      = var.vpc
  description = "Allow SSH, HTTP, HTTPS"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Security Group"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = var.vpc
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id   = var.vpc
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = {
    Name = "Private Route Table"
  }
}

resource "aws_route_table_association" "public_rt_association" {
  subnet_id = var.public_subnet_id.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rt_association" {
  subnet_id = var.private_subnet_id.id
  route_table_id = aws_route_table.private_rt.id
}