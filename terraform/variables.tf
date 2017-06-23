
variable "ubuntu-ami" {
  default = "ami-80861296"
}

variable "vpc" {
  default = "vpc-9c3af6f9"
}

variable "availability_zones" {
  type = "list"
  default = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e"]
}

variable "subnets" {
  type = "map"

  default = {
    us-east-1a = "subnet-6dbed708"
    us-east-1b = "subnet-a394b68b"
    us-east-1c = "subnet-e0806097"
    us-east-1d = "subnet-60fdff26"
    us-east-1e = "subnet-396e0e03"
  }
}

variable "drives" {
  type = "list"
  default = [
    "vol-0d7c10728cb33851e",    # us-east-1a
    "vol-0c0ec108b96d095c0",    # us-east-1b
    "vol-0f6cc1e6b6a85456a"     # us-east-1c
  ]
}

variable "num_brokers" {
  default = 3
}

variable "broker_zero_ip" {
  default = "34.207.44.218"
}

variable "eips" {
  default = [
    "34.207.44.218",
    "34.202.200.37",
    "34.225.250.141"
  ]
}

variable "chef_username" {
    default = "torontoai"
}

variable "chef_keyfile" {
    default = "~/.ssh/aws/toronto-ai.pem"
}
variable "chef_client" {
    default = "/Users/clearwhale/.chef/client.pem"
}
