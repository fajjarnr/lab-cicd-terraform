data "aws_canonical_user_id" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

# data "aws_vpc" "vpc" {
#   id = var.vpc_specs.vpc_id
# }

# data "aws_subnet" "private_subnets" {
#   for_each = toset(local.private_subnets)
#   id       = each.value
# }

# data "aws_subnet" "public_subnets" {
#   for_each = toset(local.public_subnets)
#   id       = each.value
# }

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.name
  #   azs        = slice(data.aws_availability_zones.available.names, 0, 2)
  #   prefix     = "${var.main_prefix}-${var.env}"

  #   vpc_id   = var.vpc_specs.vpc_id
  #   vpc_cidr = data.aws_vpc.vpc.cidr_block

  #   private_subnets = var.vpc_specs.private_subnets
  #   public_subnets  = var.vpc_specs.public_subnets


  #   private_subnets_cidr_blocks = [for s in data.aws_subnet.private_subnets : s.cidr_block]
  #   public_subnets_cidr_blocks  = [for s in data.aws_subnet.public_subnets : s.cidr_block]
}


data "aws_route53_zones" "all" {}

data "aws_route53_zone" "selected" {
  name         = "sandbox2511.opentlc.com"
  private_zone = false
}
