locals {
  num_subnets = min(length(data.aws_availability_zones.available.names), 3)
}

resource "aws_subnet" "subnet_priv" {
  count                   = local.num_subnets
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.my_vpc.cidr_block, 7, count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.owner_id}-subnet-priv-${count.index}"
  }

  lifecycle {
    create_before_destroy = "true"
  }
}

resource "aws_subnet" "subnet_public" {
  count                   = local.num_subnets
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.my_vpc.cidr_block, 7, length(aws_subnet.subnet_priv) + count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.owner_id}-subnet-prub-${count.index}"
  }

  lifecycle {
    create_before_destroy = "true"
  }
}

