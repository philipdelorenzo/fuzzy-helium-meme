# locals.tf
locals {
  # Get VPC ID from one of the subnets
  vpc_id = values(data.aws_subnet.aurora_subnet_details)[0].vpc_id

  # Get private subnets (assume Aurora is in private subnets)
  private_subnet_ids = [for subnet in data.aws_subnet.aurora_subnet_details : subnet.id if !subnet.map_public_ip_on_launch]

  # Get public subnets for load balancers
  public_subnet_ids = [for subnet in data.aws_subnet.aurora_subnet_details : subnet.id if subnet.map_public_ip_on_launch]

  # Common tags
  common_tags = merge(
    var.tags,
    {
      Environment = "production"
      ManagedBy   = "terraform"
      Cluster     = var.cluster_name
    }
  )
}
