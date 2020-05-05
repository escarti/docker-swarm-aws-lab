terraform {
  required_version = "0.12.24"
}

locals {
  num_subnets = length(var.priv_subnets)
}

# Key to connect to instances

resource "aws_key_pair" "keypair_auth" {
  key_name   = var.key_name
  public_key = file("${var.key_path}.pub")
}

# Create default security group for instances

resource "aws_security_group" "sg_ec2" {
  vpc_id      = var.vpc_id
  description = "Security group for EC2 instances"
  name        = "${var.owner_id}-sg-ec2"

  ingress {
    description = "Allow ssh incoming connections"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ips
  }

  #HTTP
  ingress {
    description     = "Standard http incoming"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_public_alb.id, ]
  }

  ingress {
    description = "ICMP echo reply"
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = var.allowed_ips
  }

  egress {
    description = "Allow all ports and protocols to go out"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Create manager instance and security group
resource "aws_instance" "manager_ec2" {
  instance_type = var.instance_type
  ami           = var.ami

  tags = {
    Name = "${var.owner_id}-manager-ec2"
  }

  key_name               = aws_key_pair.keypair_auth.id
  vpc_security_group_ids = [aws_security_group.sg_ec2.id]
  subnet_id              = var.pub_subnets[0]

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "y | sudo amazon-linux-extras install docker",
      "sudo service docker start",
      "sudo usermod -a -G docker ec2-user"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      password    = ""
      private_key = file(var.key_path)
      host        = self.public_ip
    }
  }
}

# Create worker ec2 instances

resource "aws_instance" "worker_ec2" {
  count = local.num_subnets

  instance_type = var.instance_type
  ami           = var.ami

  tags = {
    Name = "${var.owner_id}-worker-ec2"
  }

  key_name               = aws_key_pair.keypair_auth.id
  vpc_security_group_ids = [aws_security_group.sg_ec2.id]
  subnet_id              = var.pub_subnets[count.index]

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "y | sudo amazon-linux-extras install docker",
      "sudo service docker start",
      "sudo usermod -a -G docker ec2-user"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      password    = ""
      private_key = file(var.key_path)
      host        = self.public_ip
    }
  }


}