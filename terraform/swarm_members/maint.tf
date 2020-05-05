terraform {
  required_version = "0.12.24"
}

provider "aws" {
  version = "~> 2.46"
  region  = var.aws_region
  profile = var.aws_profile
}

resource "null_resource" "write_file" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    workers = join(",", aws_instance.worker_ec2.*.public_ip)
    manager = aws_instance.manager_ec2.public_ip
    alb_dns = aws_lb.alb.dns_name
  }

  provisioner "local-exec" {
    command = <<EOD
cat <<EOF > swarmec2.tfvars
workers = ["${join("\",\"", "${aws_instance.worker_ec2.*.public_ip}")}",]
manager  = "${aws_instance.manager_ec2.public_ip}"
alb_dns = "${aws_lb.alb.dns_name}"
EOF
EOD
  }
}