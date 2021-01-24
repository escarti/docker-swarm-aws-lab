terraform {
  required_version = "0.14.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.46"

    }
    # In the rare situation of using two providers that
    # have the same type name -- "http" in this example --
    # use a compound local name to distinguish them.
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}