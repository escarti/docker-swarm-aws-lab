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
    priv_subnets_ids = join(",", aws_subnet.subnet_priv.*.id)
    pub_subnets_ids  = join(",", aws_subnet.subnet_public.*.id)
    vpc_id           = aws_vpc.my_vpc.id
    aws_region       = var.aws_region
    owner_id         = var.owner_id
    aws_profile      = var.aws_profile
  }

  provisioner "local-exec" {
    command = <<EOD
cat <<EOF > network.tfvars
vpc_id       = "${aws_vpc.my_vpc.id}"
priv_subnets = ["${join("\",\"", "${aws_subnet.subnet_priv.*.id}")}",]
pub_subnets  = ["${join("\",\"", "${aws_subnet.subnet_public.*.id}")}",]
aws_region   = "${var.aws_region}"
owner_id     = "${var.owner_id}"
aws_profile  = "${var.aws_profile}"
EOF
EOD
  }
  depends_on = [aws_vpc.my_vpc, aws_subnet.subnet_priv, ]
}