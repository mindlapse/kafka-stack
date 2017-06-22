
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

  instance_type = "t2.small"
  ami = "${var.ubuntu-ami}"
  key_name = "toronto-ai"
  ebs_optimized = false
  vpc_security_group_ids = [
    "${aws_security_group.allow-ssh.id}",
    "${aws_security_group.allow-zk.id}",
    "${aws_security_group.allow-kafka.id}",
    "${aws_security_group.ping.id}"
  ]

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

data "aws_eip" "eips" {
  count = "${aws_instance.kafka-node.count}"
  public_ip = "${var.eips[count.index]}"
}

resource "aws_eip_association" "node_eip_assocs" {
  count = "${aws_instance.kafka-node.count}"
  instance_id = "${element(aws_instance.kafka-node.*.id, count.index)}"
  allocation_id = "${element(data.aws_eip.eips.*.id, count.index)}"
}

# Attach pre-existing drives to these instances
resource "aws_volume_attachment" "kafka-drives" {
  count = "${aws_instance.kafka-node.count}"
  device_name = "/dev/sdg"
  volume_id   = "${var.drives[count.index]}"
  instance_id = "${element(aws_instance.kafka-node.*.id, count.index)}"
  skip_destroy = true
}


output "public_ips" {
  value = ["${aws_eip_association.node_eip_assocs.*.public_ip}"]
}
output "private_ips" {
  value = ["${aws_instance.kafka-node.*.private_ip}"]
}
