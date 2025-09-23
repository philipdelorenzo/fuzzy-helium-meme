output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "aurora_cluster_endpoint" {
  description = "Aurora cluster endpoint"
  value       = module.aurora.cluster_endpoint
}

output "aurora_cluster_reader_endpoint" {
  description = "Aurora cluster reader endpoint"
  value       = module.aurora.cluster_reader_endpoint
}

output "database_name" {
  description = "Name of the database"
  value       = module.aurora.database_name
}

output "secrets_manager_secret_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = module.aurora.secrets_manager_secret_arn
}
