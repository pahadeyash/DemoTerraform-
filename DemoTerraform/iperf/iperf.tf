variable "name" {}
variable "vpc" {}
variable "subnet" {}
variable "keypair" {}
variable "region" {}
variable "userdata" {}


variable "images" {
  type = "map"
  default = {
    us-east-1 = "ami-cd0f5cb6"
    us-west-1 = "ami-09d2fb69"
  }
}

#Define the region
provider "aws" {
  region     = "${var.region}"
}

resource "aws_security_group" "iperf-sg" {
  vpc_id = "${var.vpc}"
  name        = "iperf-sg"
  description = "Iperf - Security Group"
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
    Name = "${var.name}-SG"
  }
}

resource "aws_eip" "iperf_eip" {
  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.iperf.id}"
  allocation_id = "${aws_eip.iperf_eip.id}"
}

resource "aws_network_interface" "eni-controller" {
  subnet_id = "${var.subnet}"
  security_groups = [
    "${aws_security_group.iperf-sg.id}"
  ]
  tags {
    Name = " ${var.name} interface"
  }
}

resource "aws_instance" "iperf" {
  ami           = "${lookup(var.images, var.region)}"
  instance_type = "t2.micro"
  key_name = "${var.keypair}"
  network_interface {
     network_interface_id = "${aws_network_interface.eni-controller.id}"
     device_index = 0
  }
  user_data = "${var.userdata}"
  tags {
    Name = "${var.name}"
  }
}

output "private-ip" {
    value = "${aws_instance.iperf.private_ip}"
}

output "public-ip" {
    value = "${aws_instance.iperf.public_ip}"
}
