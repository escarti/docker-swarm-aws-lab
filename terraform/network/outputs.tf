output "private_subnets_ids" {
  value = [aws_subnet.subnet_priv.*.id]
}

output "public_subnets_ids" {
  value = [aws_subnet.subnet_public.*.id]
}

output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "subnet_priv" {
  value = aws_subnet.subnet_priv
}

output "subnet_pub" {
  value = aws_subnet.subnet_public
}