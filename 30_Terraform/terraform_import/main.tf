provider "aws" {
    region = "us-east-1"
}

# ----------------VPC+subnets-------------------

resource "aws_vpc" "My_VPC" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    "Name" = "MyVPC"
    "Role" = "DevOps"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.My_VPC.id 
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true 
  availability_zone       = "us-east-1a"
  tags = {
    Name = "Public subnet"
  }
}

# ----------------IGW-------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.My_VPC.id
  tags = {
    Name = "Internet Gateway"
  }
}

# ----------------SG-------------------
resource "aws_security_group" "my_sg" {
  vpc_id      = aws_vpc.My_VPC.id
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
# ----------------RouteTable+Rules+assosiations-------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.My_VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public_rt_association" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_subnet.id
}

# ----------------Instance-import-------------------
# aws_instance.public_instance:
resource "aws_instance" "public_instance" {
    ami                                  = "ami-0866a3c8686eaeeba"
    associate_public_ip_address          = true
    availability_zone                    = "us-east-1a"
    disable_api_stop                     = false
    disable_api_termination              = false
    ebs_optimized                        = false
    get_password_data                    = false
    hibernation                          = false
    host_id                              = null
    iam_instance_profile                 = null
    instance_initiated_shutdown_behavior = "stop"
    instance_lifecycle                   = null
    instance_type                        = "t2.micro"
    key_name                             = "test_key"
    monitoring                           = false
    outpost_arn                          = null
    password_data                        = null
    placement_group                      = null
    placement_partition_number           = 0
    public_dns                           = null
    secondary_private_ips                = []
    security_groups                      = []
    source_dest_check                    = true
    spot_instance_request_id             = null
    subnet_id                            = aws_subnet.public_subnet.id
    tags                                 = {
        "Name"   = "My EC2 instance from terraform"
        "subnet" = "public_instance"
    }
    tags_all                             = {
        "Name"   = "My EC2 instance from terraform"
        "subnet" = "public_instance"
    }
    tenancy                              = "default"
    vpc_security_group_ids               = [
        aws_security_group.my_sg.id
    ]

    capacity_reservation_specification {
        capacity_reservation_preference = "open"
    }

    cpu_options {
        amd_sev_snp      = null
        core_count       = 1
    }

    credit_specification {
        cpu_credits = "standard"
    }

    enclave_options {
        enabled = false
    }

    maintenance_options {
        auto_recovery = "default"
    }

    metadata_options {
        http_endpoint               = "enabled"
        http_protocol_ipv6          = "disabled"
        http_put_response_hop_limit = 2
        http_tokens                 = "required"
        instance_metadata_tags      = "disabled"
    }

    private_dns_name_options {
        enable_resource_name_dns_a_record    = false
        enable_resource_name_dns_aaaa_record = false
        hostname_type                        = "ip-name"
    }

    root_block_device {
        delete_on_termination = true
        encrypted             = false
        iops                  = 3000
        kms_key_id            = null
        tags                  = {}
        tags_all              = {}
        throughput            = 125
        volume_size           = 8
        volume_type           = "gp3"
    }
}