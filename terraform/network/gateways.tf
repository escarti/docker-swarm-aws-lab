terraform {
  required_version = "0.12.24"
}

# Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${var.owner_id}-igw"
  }
}

# NAT gateways, one per AZ
resource "aws_eip" "nat" {
  count = local.num_subnets
  vpc   = true
}

resource "aws_nat_gateway" "natgw" {
  count         = local.num_subnets
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.subnet_public[count.index].id
  depends_on    = [aws_internet_gateway.igw, ]

  tags = {
    Name = "${var.owner_id}-natgw-${count.index}"
  }
}

