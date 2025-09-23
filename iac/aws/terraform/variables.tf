variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "REGION" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "DB_NAME" {
  description = "Name of the database"
  type        = string
  default     = "appdb"
}

variable "DB_USERNAME" {
  # This should be provided when the module is used, as TF_VAR_DB_USERNAME - See Doppler
  description = "Master username for the database"
  type        = string
  default     = "dbadmin"
}

variable "DB_PASSWORD" {
  # This should be provided when the module is used, as TF_VAR_DB_PASSWORD - See Doppler
  description = "Password for the database user"
  type        = string
  sensitive   = true
}

variable "aurora_instance_class" {
  description = "Instance class for Aurora instances"
  type        = string
  default     = "db.t4g.micro"
}

variable "aurora_instance_count" {
  description = "Number of Aurora instances"
  type        = number
  default     = 2
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 0
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
