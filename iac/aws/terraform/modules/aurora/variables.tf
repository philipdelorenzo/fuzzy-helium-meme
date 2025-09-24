variable "name_prefix" {
  description = "Name prefix for resources"
  type        = string
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

variable "aurora_family_type" {
  description = "The database version - e.g., postgresql15"
  type        = string
  default     = "aurora-postgresql15"
}

variable "instance_class" {
  description = "Instance class for Aurora instances"
  type        = string
}

variable "instance_count" {
  description = "Number of Aurora instances"
  type        = number
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for Aurora"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "Application security group ID"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}