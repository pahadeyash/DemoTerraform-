provider "aws" {
  profile = "demo"
}

module "vpc-west" {
  source = "./vpc"
  region  = "us-west-1"
  cidr_block = "10.0"
}

module "vpc-east" {
  source = "./vpc"
  region   = "us-east-1"
  cidr_block = "192.168"
}

module "iperf-server" {
  name = "Server"
  region  = "us-west-1"
  source = "./iperf"
  vpc = "${module.vpc-west.vpc_id}"
  subnet = "${module.vpc-west.public_subnet_id}"
  keypair = "AviatrixDemo"
  userdata = "${file("./iperf/server_userdata.txt")}"
}

module "iperf-client" {
  name = "Client"
  source = "./iperf"
  region   = "us-east-1"
  vpc = "${module.vpc-east.vpc_id}"
  subnet = "${module.vpc-east.public_subnet_id}"
  keypair = "AviatrixDemo"
  userdata = "${file("./iperf/client_userdata.txt")}"
}

output "iperf-client-private-ip" {
    value = "${module.iperf-client.private-ip}"
}

output "iperf-server-private-ip" {
    value = "${module.iperf-server.private-ip}"
}

output "iperf-server-public-ip" {
    value = "${module.iperf-server.public-ip}"
}
output "iperf-client-public-ip" {
    value = "${module.iperf-client.public-ip}"
}

module "iam_roles" {
  source = "github.com/AviatrixSystems/terraform-modules.git/iam_roles"
  region  = "us-west-1"
}

module "aviatrixcontroller" {
  source = "github.com/AviatrixSystems/terraform-modules.git/controller"
  region  = "us-west-1"
  vpc = "${module.vpc-west.vpc_id}"
  subnet = "${module.vpc-west.public_subnet_id}"
  keypair = "AviatrixDemo"
  ec2role = "${module.iam_roles.aviatrix-role-ec2}"
}

output "aviatrixcontroller-private-ip" {
  value = "${module.aviatrixcontroller.private-ip}"
}

output "aviatrixcontroller-public-ip" {
  value = "${module.aviatrixcontroller.public-ip}"
}

module "windows" {
  source = "./windows"
  region   = "us-east-1"
  vpc = "${module.vpc-east.vpc_id}"
  subnet = "${module.vpc-east.public_subnet_id}"
  keypair = "AviatrixDemo"
  userdata = "${file("./iperf/iperf_userdata.txt")}"
}
