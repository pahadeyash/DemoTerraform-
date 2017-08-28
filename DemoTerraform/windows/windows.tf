variable "vpc" {}
variable "subnet" {}
variable "keypair" {}
variable "region" {}
variable "userdata" {}


variable "images" {
  type = "map"
  default = {
    us-east-1 = "ami-d4dfd1c2"
    us-west-1 = "ami-1f18367f"
  }
}

#Define the region
provider "aws" {
  region     = "${var.region}"
}

resource "aws_security_group" "windows-sg" {
  vpc_id = "${var.vpc}"
  name        = "windows-sg"
  description = "windows - Security Group"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags {
    Name = "windows-SG"
  }
}

resource "aws_eip" "windows_eip" {
  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.windows.id}"
  allocation_id = "${aws_eip.windows_eip.id}"
}

resource "aws_network_interface" "eni-controller" {
  subnet_id = "${var.subnet}"
  security_groups = [
    "${aws_security_group.windows-sg.id}"
  ]
  tags {
    Name = " windows interface"
  }
}

resource "aws_instance" "windows" {
  ami           = "${lookup(var.images, var.region)}"
  instance_type = "t2.micro"
  key_name = "${var.keypair}"
  network_interface {
     network_interface_id = "${aws_network_interface.eni-controller.id}"
     device_index = 0
  }
  tags {
    Name = "windows"
  }
}

output "private-ip" {
    value = "${aws_instance.windows.private_ip}"
}

output "public-ip" {
    value = "${aws_instance.windows.public_ip}"
}
