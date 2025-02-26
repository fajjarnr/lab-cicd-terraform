module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.33.1"

  cluster_name    = "mycluster"
  cluster_version = "1.32"

  # EKS Addons
  cluster_addons = {
    coredns = {
      must_recent = true
    }
    eks-pod-identity-agent = {
      must_recent = true
    }
    kube-proxy = {
      must_recent = true
    }
    vpc-cni = {
      must_recent = true
    }
    aws-ebs-csi-driver = {
      must_recent = true
    }
    aws-efs-csi-driver = {
      must_recent = true
    }
  }

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    ami_type       = "AL2023_x86_64_STANDARD"
    instance_types = ["m5.xlarge", "m5.2xlarge", "m5.4xlarge"]

    attach_cluster_primary_security_group = true
  }

  eks_managed_node_groups = {
    worker = {
      instance_types = ["m5.xlarge"]

      min_size     = 2
      max_size     = 5
      desired_size = 2
    }
  }

  depends_on = [module.vpc]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
