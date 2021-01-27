output "alb_dns" {
  value = aws_lb.alb.dns_name
}

output "suffix" {
  value = random_string.suffix.result
}