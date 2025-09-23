# Aurora Cluster Parameter Group
resource "aws_rds_cluster_parameter_group" "aurora" {
  family      = var.aurora_family_type
  name        = "${var.name_prefix}-aurora-cluster-pg"
  description = "Aurora cluster parameter group"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-aurora-cluster-pg"
  })
}

# Aurora DB Parameter Group
resource "aws_db_parameter_group" "aurora" {
  family = var.aurora_family_type
  name   = "${var.name_prefix}-aurora-db-pg"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-aurora-db-pg"
  })
}
