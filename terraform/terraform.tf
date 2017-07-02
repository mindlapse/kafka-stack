
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
    Hello = "World-${count.index}"
  }

}





# Reference some pre-created elastic IPs that we'll want to associate
# with our instances
data "aws_eip" "eips" {
  count = "${aws_instance.kafka-node.count}"
  public_ip = "${var.eips[count.index]}"
}



# Associate our elastic IPs to the EC2 instances
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


data "template_file" "json" {
  count = "${aws_instance.kafka-node.count}"
  template = "{ \"broker_id\" : \"$${broker_id}\", \"zk_ips\" : $${zk_ips} }"
  vars {
    broker_id = "${count.index+1}"
    zk_ips = "${jsonencode(aws_instance.kafka-node.*.private_ip)}"
  }
}

# A null_resource is just an empty node in a terraform graph,
# but you can use it to start provisioning after other resources have been created
resource "null_resource" "terraforming" {
  count = "${aws_instance.kafka-node.count}"

  depends_on = [
    "aws_volume_attachment.kafka-drives",
    "aws_eip_association.node_eip_assocs"
  ]
  provisioner "chef" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file(var.chef_keyfile)}"
      host        = "${element(data.aws_eip.eips.*.public_ip, count.index)}"
      agent       = false
    }
    attributes_json = "${element(data.template_file.json.*.rendered, count.index)}"
    node_name   = "kafka-node-${count.index}"
    run_list    = ["kafka-node::default"]
    server_url  = "https://manage.chef.io/organizations/toronto-ai"
    user_key    = "${file(var.chef_client)}"
    user_name   = "${var.chef_username}"
    recreate_client = true
  }
}


# Print out the public IPs of our instances, for convenience.
output "public_ips" {
  value = ["${aws_eip_association.node_eip_assocs.*.public_ip}"]
}


# Print out the private IPs of our instances, again this is just for convenience.
output "private_ips" {
  value = ["${aws_instance.kafka-node.*.private_ip}"]
}
