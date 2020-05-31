variable "priv_subnets" {
  type = list(string)
}
variable "pub_subnets" {
  type = list(string)
}

variable "vpc_id" {}

variable "owner_id" {}

variable "aws_region" {}

variable "aws_profile" {}

variable "ami" {
  # default for us-east-1
  default = "ami-0323c3dd2da7fb37d"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "docker-swarm-key"
}

variable "key_path" {
  default = "~/.ssh/docker-swarm-key"
}

variable "allowed_ips" {
  default = ["0.0.0.0/0", ]
}