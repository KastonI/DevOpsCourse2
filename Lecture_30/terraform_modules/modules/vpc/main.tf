resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "Vpc"
    Homework = "Lecture_30"
  }
}

resource "aws_subnet" "public" {
  cidr_block = var.public_subnet_cidr
  vpc_id = aws_vpc.vpc.id
  availability_zone = var.az_zone
  map_public_ip_on_launch = true
  tags = { Name = "Public subnet"}
}

resource "aws_subnet" "private" {
  cidr_block = var.private_subnet_cidr
  vpc_id = aws_vpc.vpc.id
  availability_zone = var.az_zone
  map_public_ip_on_launch = false
  tags = { Name = "Private subnet"}
}