# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# Networking Module
module "networking" {
  source = "./modules/networking"

  name_prefix        = local.name_prefix
  vpc_cidr           = var.vpc_cidr
  availability_zones = data.aws_availability_zones.available.names
  tags               = local.common_tags
}

# Security Module
module "security" {
  source = "./modules/security"

  name_prefix = local.name_prefix
  tags        = local.common_tags
}

# Aurora Module
module "aurora" {
  source = "./modules/aurora"

  name_prefix             = local.name_prefix
  DB_NAME                 = var.DB_NAME
  DB_USERNAME             = var.DB_USERNAME
  DB_PASSWORD             = var.DB_PASSWORD
  instance_class          = var.aurora_instance_class
  instance_count          = var.aurora_instance_count
  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection

  # From other modules
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_subnet_ids
  app_security_group_id = module.networking.app_security_group_id
  kms_key_arn           = module.security.kms_key_arn

  tags = local.common_tags
}
