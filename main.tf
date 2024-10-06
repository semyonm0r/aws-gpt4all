provider "aws" {
  region = var.aws_region
}

module "network" {
  source     = "./modules/network"
  tag_prefix = var.tag_prefix
}

module "ec2" {
  source            = "./modules/ec2"
  ami_id            = var.ami_id
  instance_type     = var.instance_type
  subnet_id         = module.network.subnet_id
  key_name          = var.key_name
  security_group_id = module.network.security_group_id
  tag_prefix        = var.tag_prefix
  aws_azs           = var.aws_azs
  ebs_size          = var.ebs_size
}
