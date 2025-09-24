# main.tf
# Main configuration file for EKS cluster with Aurora connectivity
# This file contains the core configuration and can include additional resources

# Optional: CloudWatch Log Group for EKS cluster logs
resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 7
  
  tags = merge(
    local.common_tags,
    {
      Name = "${var.cluster_name}-cluster-logs"
    }
  )
}

# Optional: KMS key for EKS secrets encryption
resource "aws_kms_key" "eks_secrets" {
  description             = "KMS key for EKS secrets encryption"
  deletion_window_in_days = 7
  
  tags = merge(
    local.common_tags,
    {
      Name = "${var.cluster_name}-secrets-key"
    }
  )
}

resource "aws_kms_alias" "eks_secrets" {
  name          = "alias/${var.cluster_name}-secrets"
  target_key_id = aws_kms_key.eks_secrets.key_id
}

# Optional: Create a dedicated service account for database access
resource "aws_iam_role" "database_access_role" {
  name = "${var.cluster_name}-database-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${aws_iam_openid_connect_provider.eks.url}:sub" = "system:serviceaccount:default:database-access"
            "${aws_iam_openid_connect_provider.eks.url}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = local.common_tags
}

# Policy for accessing AWS Secrets Manager (for database credentials)
resource "aws_iam_policy" "database_secrets_policy" {
  name        = "${var.cluster_name}-database-secrets-policy"
  description = "Policy for accessing database secrets from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:${var.REGION}:*:secret:${var.cluster_name}/*"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "database_secrets_policy_attachment" {
  role       = aws_iam_role.database_access_role.name
  policy_arn = aws_iam_policy.database_secrets_policy.arn
}
