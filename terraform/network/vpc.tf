terraform {
  required_version = "0.12.24"
}

resource "aws_vpc" "my_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.owner_id}-vpc"
  }
}