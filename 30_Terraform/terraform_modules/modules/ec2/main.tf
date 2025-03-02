resource "aws_instance" "private_instance" {
    count = var.private_instance
    ami             = var.ami_id
    instance_type   = var.instance_type
    subnet_id = var.private_subnet_id.id
    security_groups = [ var.sg ]
    tags = {
        Name = "Test istance ${count.index +1}"
    }
}

resource "aws_instance" "public_instance" {
    count = var.public_instance
    ami             = var.ami_id
    instance_type   = var.instance_type
    subnet_id = var.public_subnet_id.id
    security_groups = [ var.sg ]
    tags = {
        Name = "Test istance ${count.index +1}"
    }
}