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