variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.2.0/24"
}

variable "az_zone" {
  default = "us-east-1a"
}

variable "ami_id" {
  default = "ami-0866a3c8686eaeeba"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "test_key"
}

variable "public_instance" {
  default = "2"
}

variable "private_instance" {
  default = "2"
}
