resource "null_resource" "write_file" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    alb_dns_name = aws_lb.alb.dns_name
  }

  provisioner "local-exec" {
    command = <<EOD
cat <<EOF > fargate.tfvars
alb_dns = "${aws_lb.alb.dns_name}"
EOF
EOD
  }
}