# eks.tf
# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.CLUSTER_NAME
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = data.aws_db_subnet_group.aurora.subnet_ids
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  # Enable EKS Cluster Control Plane Logging
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = merge(
    local.common_tags,
    {
      Name = var.CLUSTER_NAME
    }
  )
}

# EKS Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.CLUSTER_NAME}-nodes"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = length(local.private_subnet_ids) > 0 ? local.private_subnet_ids : data.aws_db_subnet_group.aurora.subnet_ids

  capacity_type  = var.node_capacity_type
  instance_types = var.node_instance_types

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  update_config {
    max_unavailable_percentage = 25
  }

  # Remote access configuration (optional)
  dynamic "remote_access" {
    for_each = var.ec2_ssh_key != null ? [1] : []
    content {
      ec2_ssh_key               = var.ec2_ssh_key
      source_security_group_ids = [aws_security_group.eks_node_sg.id]
    }
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling
  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_registry_policy,
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.CLUSTER_NAME}-nodes"
    }
  )

  # Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

resource "aws_eks_access_entry" "github_actions_ci" {
  cluster_name      = var.CLUSTER_NAME
  principal_arn     = var.OIDC_ROLE
  depends_on = [aws_eks_cluster.main]
}

resource "aws_eks_access_policy_association" "github_actions_admin_policy" {
  cluster_name = aws_eks_cluster.main.name
  principal_arn = aws_eks_access_entry.github_actions_ci.principal_arn
  policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
}