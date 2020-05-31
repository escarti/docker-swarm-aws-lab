variable "owner_id" {}

variable "aws_region" {}

variable "aws_profile" {}

variable "image" {
  default = "escarti/simple-flask-web:latest"
}

variable "container_port" {
  default = "5000"
}

variable "host_port" {
  default = "5000"
}

variable "app_count" {
  default = 3
}

variable "fargate_cpu" {
  default = "1024"
}

variable "fargate_memory" {
  default = 2048
}

variable "allowed_ips" {
  default = ["0.0.0.0/0", ]
}

variable "priv_subnets" {
  type = list(string)
}

variable "pub_subnets" {
  type = list(string)
}

variable "vpc_id" {}