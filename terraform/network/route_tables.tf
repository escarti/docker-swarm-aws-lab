terraform {
  required_version = "0.12.24"
}

# Private routing-tables
resource "aws_route_table" "routetable_private" {
  count  = local.num_subnets
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw[count.index].id
  }

  tags = {
    Name = "${var.owner_id}-routetable-priv-${count.index}"
  }
}

resource "aws_route_table_association" "rtassoc-priv" {
  count          = local.num_subnets
  subnet_id      = aws_subnet.subnet_priv[count.index].id
  route_table_id = aws_route_table.routetable_private[count.index].id
}

# Public routing tables

resource "aws_route_table" "routetable_public" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.owner_id}-routetable-pub"
  }
}

resource "aws_route_table_association" "rtassoc-pub" {
  count          = local.num_subnets
  subnet_id      = aws_subnet.subnet_public[count.index].id
  route_table_id = aws_route_table.routetable_public.id
}
