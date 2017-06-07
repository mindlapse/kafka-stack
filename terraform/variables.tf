
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