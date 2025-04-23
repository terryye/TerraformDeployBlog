provider "aws" {
  region = "us-east-1"
}

module "network" {
  source = "./modules/network"
}

module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.network.vpc_id
}

module "rds" {
  source             = "./modules/rds"
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  db_security_group_id = module.security_groups.rds_security_group_id
  ec2_security_group_id = module.security_groups.ec2_security_group_id
}

module "ec2" {
  source               = "./modules/ec2"
  subnet_ids           = module.network.private_subnet_ids
  ec2_security_group_id = module.security_groups.ec2_security_group_id
  db_host              = module.rds.db_instance_address
  db_port              = module.rds.db_instance_port
  db_username          = module.rds.db_username
  db_password          = module.rds.db_password
  db_name              = module.rds.db_name
}

module "alb" {
  source           = "./modules/alb"
  vpc_id           = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_security_group_id
}

module "autoscaling" {
  source           = "./modules/autoscaling"
  subnet_ids       = module.network.private_subnet_ids
  target_group_arn = module.alb.target_group_arn
  launch_template_id = module.ec2.launch_template_id
}