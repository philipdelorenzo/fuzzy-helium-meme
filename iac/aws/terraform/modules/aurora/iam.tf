# Let's add any IAM resources we need for Aurora Serverless

resource "aws_iam_policy" "rds_describe_policy" {
  name        = "rds-describe-db-engine-versions-policy"
  description = "Allows the user to describe RDS database engine versions"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "rds:DescribeDBEngineVersions",
      "Resource": "*"
    }
  ]
}
EOF
}
