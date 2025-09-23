provider "aws" {
  region  = var.REGION
  profile = var.profile
}

terraform {
  backend "s3" {
    bucket  = "helium-cluster-terraform-state"
    key     = "aurora/dev/terraform.tfstate"
    profile = var.profile
    region  = "us-west-2"
  }
}

module "aurora_stack" {
  source = "../../"

  project_name            = var.project_name
  environment             = "dev"
  REGION                  = var.REGION      # TF_VAR_REGION must be set in your environment or Doppler
  DB_NAME                 = var.DB_NAME     # TF_VAR_DATABASE_NAME must be set in your environment or Doppler
  DB_USERNAME             = var.DB_USERNAME # TF_VAR_DB_USERNAME must be set in your environment or Doppler
  DB_PASSWORD             = var.DB_PASSWORD # TF_VAR_DB_PASSWORD must be set in your environment or Doppler
  aurora_instance_class   = "db.t3.micro"
  aurora_instance_count   = 1
  deletion_protection     = false
  backup_retention_period = 0

  tags = {
    Owner       = "Dev Team"
    Environment = "development"
  }
}
