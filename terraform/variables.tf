data "aws_availability_zones" "available" {
}

variable "owner_id" {
  default = "ironman"
}

variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "aws_profile" {
  default = "docker-swarm-aws"
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

variable "swarm_mode" {
  default = true 
}

variable "fargate_mode" {
  default = false 
}

variable "image" {}