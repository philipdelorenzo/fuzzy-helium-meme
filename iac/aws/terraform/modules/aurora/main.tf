# DB Subnet Group
resource "aws_db_subnet_group" "aurora" {
  name       = "${var.name_prefix}-aurora-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-aurora-subnet-group"
  })
}

# Security Group for Aurora (references app security group)
resource "aws_security_group" "aurora" {
  name_prefix = "${var.name_prefix}-aurora-"
  vpc_id      = var.vpc_id
  description = "Security group for Aurora database"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
    description     = "PostgreSQL/Aurora access from application"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-aurora-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Secrets Manager for Database Password
resource "aws_secretsmanager_secret" "db_password" {
  name        = "${var.name_prefix}-db-credentials"
  description = "Database credentials for Aurora cluster"

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = var.DB_USERNAME
    password = var.DB_PASSWORD
    engine   = "postgresql"
    host     = aws_rds_cluster.aurora.endpoint
    port     = 5432
    dbname   = var.DB_NAME
  })
}

# Aurora Cluster
resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "${var.name_prefix}-aurora"
  engine                  = "aurora-postgresql"
  engine_version          = "15"
  database_name           = var.DB_NAME
  master_username         = var.DB_USERNAME
  master_password         = var.DB_PASSWORD
  #backup_retention_period = var.backup_retention_period
  #preferred_backup_window = "07:00-09:00"
  #preferred_maintenance_window = "sun:05:00-sun:06:00"
  
  # Security
  storage_encrypted              = true
  kms_key_id                      = var.kms_key_arn
  vpc_security_group_ids          = [aws_security_group.aurora.id]
  db_subnet_group_name            = aws_db_subnet_group.aurora.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora.name
  
  # Backup and Monitoring
  copy_tags_to_snapshot = true
  deletion_protection   = var.deletion_protection
  skip_final_snapshot   = true
  #final_snapshot_identifier = "${var.name_prefix}-aurora-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  
  # Enable logging
  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-aurora"
  })

  lifecycle {
    ignore_changes = [master_password]
  }
}

# Aurora Cluster Instances
resource "aws_rds_cluster_instance" "aurora" {
  count              = var.instance_count
  identifier         = "${var.name_prefix}-aurora-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version
  
  # Security
  publicly_accessible = false
  
  # Monitoring
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.enhanced_monitoring.arn
  
  # Performance Insights
  performance_insights_enabled    = true
  performance_insights_kms_key_id = var.kms_key_arn
  
  db_parameter_group_name = aws_db_parameter_group.aurora.name

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-aurora-${count.index + 1}"
  })
}
