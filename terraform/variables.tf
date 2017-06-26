
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
    "vol-0bfdedab330270c38",    # us-east-1a
    "vol-09d1ff517a22a16ef",    # us-east-1b
    "vol-0b225d9810231b08c"     # us-east-1c
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
    default = "C:\\Users\\sk8rX\\.chef\\client.pem"
}
