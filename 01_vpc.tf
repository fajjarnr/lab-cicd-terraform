module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  default_security_group_ingress = [
    {
      description = "Allow all inbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  default_security_group_egress = [
    {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  name = "project-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  private_subnets = ["10.0.144.0/20", "10.0.160.0/20", "10.0.128.0/20"]
  public_subnets  = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true
  enable_dns_support     = true

  public_subnet_tags = {
    "map_public_ip_on_launch" = "true"
    "kubernetes.io/role/elb"  = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = {
    Terraform = "true"
  }
}
