# Let's fetch some data we need for our Aurora setup

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}