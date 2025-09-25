variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "CLUSTER_NAME" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "OIDC_ROLE" {
  description = "OIDC role for the EKS cluster"
  type        = string
}

variable "REGION" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "default"
}

variable "DB_NAME" {
  description = "Name of the database"
  type        = string
}

variable "DB_USERNAME" {
  # This should be provided when the module is used, as TF_VAR_DB_USERNAME - See Doppler
  description = "Master username for the database"
  type        = string
}

variable "DB_PASSWORD" {
  # This should be provided when the module is used, as TF_VAR_DB_PASSWORD - See Doppler
  description = "Password for the database user"
  type        = string
  sensitive   = true
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}