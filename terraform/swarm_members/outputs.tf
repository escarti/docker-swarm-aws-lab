output "alb_dns" {
  value = aws_lb.alb.dns_name
}

output "worker_public_ips" {
  value = [aws_instance.worker_ec2.*.public_ip]
}

output "manager_public_ip" {
  value = aws_instance.manager_ec2.public_ip
}