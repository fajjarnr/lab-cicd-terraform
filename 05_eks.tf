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
  enable_irsa                              = true

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


module "lb_controller_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                              = "aws-load-balancer-controller"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}


resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.lb_controller_role.iam_role_arn
  }

  depends_on = [module.eks]
}
