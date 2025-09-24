# IAM Role for Enhanced Monitoring
resource "aws_iam_role" "enhanced_monitoring" {
  name = "${var.name_prefix}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "enhanced_monitoring" {
  role       = aws_iam_role.enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "aurora_error" {
  name              = "/aws/rds/cluster/${aws_rds_cluster.aurora.cluster_identifier}/error"
  retention_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-aurora-error-logs"
  })
}

resource "aws_cloudwatch_log_group" "aurora_general" {
  name              = "/aws/rds/cluster/${aws_rds_cluster.aurora.cluster_identifier}/general"
  retention_in_days = 3

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-aurora-general-logs"
  })
}

resource "aws_cloudwatch_log_group" "aurora_slowquery" {
  name              = "/aws/rds/cluster/${aws_rds_cluster.aurora.cluster_identifier}/slowquery"
  retention_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-aurora-slowquery-logs"
  })
}
