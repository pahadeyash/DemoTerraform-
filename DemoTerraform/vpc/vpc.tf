variable "region" {}
variable "cidr_block" {}

#Define the region
provider "aws" {
  region     = "${var.region}"
}

#Define the key
resource "aws_key_pair" "AviatrixDemo" {
  key_name = "AviatrixDemo"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5zl4u5UBLC3PFBUzrTit1jw+jU0JW1dIw53qw5SkRlo/j6oxBL/mUU9EHmOCPs2XjmI+WoTMpN8L/0bTuhRl1r0mdgXzKSScA6trUNtFTCpq65QhPoj85OKpO8UiLLYD7FYkmi5DvJOYggOh1CblerTFJPLA63WKPm/G72Q+v4tpQZX2I+Kb6R4t9ylf36zyIcpFiiaYiyupVwGQotRx8QaRT1FtVqc3VkOayCXSg8LQlJH5/H+KKdFt0INplACw5ionFHPrcKVI25xKs1X/CvKAfPCXK7zW5GYNjzwa8R/YZzSaIuF90+qyoJJEFYO/iCN54BLxw4mDRPPd5F54x jorgebonilla@ITs-MacBook-Pro.local"  
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block       = "${var.cidr_block}.0.0/16"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
  tags {
    Name = "test_vpc_${var.region}"
  }
}

#Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"
  tags {
    Name = "test_igw"
  }
}

resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
  tags {
    Name = "Public RT"
  }
}

# Public subnet
resource "aws_subnet" "public" {
	vpc_id = "${aws_vpc.main.id}"
	cidr_block = "${var.cidr_block}.1.0/24"
	availability_zone = "${var.region}a"
  tags {
    Name = "Public Subnet"
  }
}

# Routing table for public subnet
resource "aws_route_table" "public" {
	vpc_id = "${aws_vpc.main.id}"
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.main.id}"
	}
  tags {
    Name = "Public RT"
  }
}

resource "aws_route_table_association" "public" {
	subnet_id = "${aws_subnet.public.id}"
	route_table_id = "${aws_route_table.public.id}"
}

# Private subsets
resource "aws_subnet" "private" {
	vpc_id = "${aws_vpc.main.id}"
	cidr_block = "${var.cidr_block}.2.0/24"
	availability_zone = "${var.region}a"
  tags {
    Name = "Private Subnet"
  }
}

# Routing table for private subnets
resource "aws_route_table" "private" {
	vpc_id = "${aws_vpc.main.id}"
  tags {
    Name = "Private RT"
  }
}

resource "aws_route_table_association" "private" {
	subnet_id = "${aws_subnet.private.id}"
	route_table_id = "${aws_route_table.private.id}"
}

output "vpc_id" {
    value = "${aws_vpc.main.id}"
}

output "public_subnet_id" {
    value = "${aws_subnet.public.id}"
}

output "private_subnet_id" {
    value = "${aws_subnet.private.id}"
}
