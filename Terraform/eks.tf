
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}



module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "wanderlust-cluster"
  kubernetes_version = "1.33"

  # Optional
  endpoint_public_access = true
  endpoint_private_access = false
  # endpoint_public_access_cidrs = ["152.56.165.186/32"]
  enable_cluster_creator_admin_permissions = false


  
  access_entries = {
    wanderlust = {
      principal_arn = "arn:aws:iam::010526243526:user/shivam"

      policy_associations = {
        wanderlust = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
  

  addons = {
    coredns                = {
        most_recent = true
    }
    kube-proxy             = {
        most_recent = true
    }
    vpc-cni                = {
      most_recent = true
      before_compute = true
    }
  }

 

  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.default.ids
  control_plane_subnet_ids = data.aws_subnets.default.ids


  eks_managed_node_groups = {
    wanderlust-ng = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t2.medium"]
      attach_cluster_primary_security_group = true
      min_size     = 2
      max_size     = 3
      desired_size = 2
     
      disk_size = 30
      iam_role_arn = "arn:aws:iam::010526243526:role/eks-nodegroup-role"

      
    }
  }

  tags = {
    Name        = "wanderlust-node-group"
    Environment = "prod"
  }
}