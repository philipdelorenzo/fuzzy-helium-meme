# data.tf
# Data sources to get existing VPC and subnets used by Aurora
data "aws_db_subnet_group" "aurora" {
  name = var.aurora_subnet_group_name
}

data "aws_subnets" "aurora_subnets" {
  filter {
    name   = "subnet-id"
    values = data.aws_db_subnet_group.aurora.subnet_ids
  }
}

data "aws_subnet" "aurora_subnet_details" {
  for_each = toset(data.aws_db_subnet_group.aurora.subnet_ids)
  id       = each.value
}

# IAM policy document for RDS and EC2 describe actions
data "aws_iam_policy_document" "rds_and_ec2_policy" {
  statement {
    effect = "Allow"
    actions = [
      "rds:DescribeDBSubnetGroups",
      "rds:DescribeDBClusters",
      "rds:DescribeDBInstances"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeAvailabilityZones"
    ]
    resources = ["*"]
  }
}