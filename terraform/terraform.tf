
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
  count = "${var.num_brokers}"

  availability_zone = "${var.availability_zones[count.index%5]}"
  subnet_id = "${var.subnets[var.availability_zones[count.index%5]]}"

  instance_type = "t2.micro"
  ami = "${var.ubuntu-ami}"
  key_name = "toronto-ai"
  ebs_optimized = false
  vpc_security_group_ids = ["${aws_security_group.allow-ssh.id}"]

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
    iops = 100
  }

  tags {
    Name = "kafka-node-${count.index}"
  }

  # provisioner "chef" {
  #   node_name   = "kafka-node-${count.index}"
  #   run_list    = ["kafka-node::default"]
  #   server_url  = "https://manage.chef.io/organizations/toronto-ai"
  #   user_name   = "${var.chef_username}"
  #   user_key    = "${file(var.chef_keyfile)}"
  # }
}

data "aws_eip" "broker_zero" {
  public_ip = "${var.broker_zero_ip}"
}

resource "aws_eip_association" "broker_zero_eip" {
    instance_id = "${aws_instance.kafka-node.0.id}"
    allocation_id = "${data.aws_eip.broker_zero.id}"
}


resource "aws_security_group" "allow-ssh" {
  name        = "allow_ssh"


  ingress {
    from_port       = 0
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

output "broker_zero_ip" {
  value = "${aws_eip.broker_zero.public_ip}"
}

output "instance_ips" {
  value = ["${aws_instance.kafka-node.*.public_ip}"]
}
