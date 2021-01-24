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