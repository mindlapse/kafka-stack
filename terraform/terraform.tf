
provider "aws" {

  region     = "us-east-1"

}

//data "aws_vpc" "main_vpc" {
//  id = "${var.vpc}"
//}
//
//resource "aws_alb" "kafka-alb" {
//  name = "kafka-alb"
//  internal = false
//  subnets = "${var.subnets}"
//  vpc_id = "${data.aws_vpc.main_vpc.id}"
//}

resource "aws_instance" "kafka-node" {
  count = 2

  availability_zone = "${var.availability_zones[count.index%5]}"
  subnet_id = "${var.subnets[var.availability_zones[count.index%5]]}"

  instance_type = "t2.micro"
  ami = "${var.ubuntu-ami}"
  key_name = "torontoai"
  ebs_optimized = false
  vpc_security_group_ids = ["${aws_security_group.allow-ssh.id}"]

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
    iops = 0
  }
  tags {
    Name = "kafka-node-${count.index}"
  }

}

resource "aws_security_group" "allow-ssh" {
  name        = "allow_ssh"


  ingress {
    from_port   = 0
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]

  }
}