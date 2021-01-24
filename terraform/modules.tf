
module "network" {
  source      = "./network"
  owner_id    = var.owner_id
  cidr_block  = var.cidr_block
  aws_region  = var.aws_region
  aws_profile = var.aws_profile
}

module "swarm" {
  count = var.swarm_mode ? 1 : 0

  source       = "./swarm_members"
  owner_id     = var.owner_id
  vpc_id       = module.network.vpc_id
  priv_subnets = module.network.subnet_priv.*.id
  pub_subnets  = module.network.subnet_pub.*.id
  aws_region   = var.aws_region
  aws_profile  = var.aws_profile
}

module "fargate" {
  count = var.fargate_mode ? 1 : 0
  
  source       = "./fargate"
  owner_id     = var.owner_id
  vpc_id       = module.network.vpc_id
  priv_subnets = module.network.subnet_priv.*.id
  pub_subnets  = module.network.subnet_pub.*.id
  aws_region   = var.aws_region
  aws_profile  = var.aws_profile
  image        = var.image

}