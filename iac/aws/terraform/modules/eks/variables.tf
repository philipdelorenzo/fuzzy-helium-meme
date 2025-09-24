# variables.tf
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "my-eks-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "REGION" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "aurora_subnet_group_name" {
  description = "Name of existing Aurora subnet group"
  type        = string
}

variable "aurora_security_group_id" {
  description = "Security group ID of existing Aurora database"
  type        = string
}

variable "node_instance_types" {
  description = "Instance types for EKS node group"
  type        = list(string)
  default     = ["t3.nano"]
}

variable "node_capacity_type" {
  description = "Capacity type for node group (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"
}

variable "node_desired_size" {
  description = "Desired number of nodes"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 4
}

variable "node_min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "ec2_ssh_key" {
  description = "EC2 Key Pair name for node group remote access"
  type        = string
  default     = null
}

variable "database_port" {
  description = "Database port for Aurora PostgreSQL"
  type        = number
  default     = 5432
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
