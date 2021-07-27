# Define the local variables for cluster name
locals {
  cluster_name = "asantra-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

data "aws_eks_cluster" "eks_cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

# Provision EKS cluster with managed node group

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.20"
  subnets         = module.vpc.private_subnets

  tags = {
    Environment = "test"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  vpc_id = module.vpc.vpc_id

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 50
  }

  # Try to emulate the actual infratructure where the node-group-2 has taints 
  # to deploy for test environment.
  node_groups = {
    node_group_1 = {
      desired_capacity = var.node_group_1_desired_capacity
      max_capacity     = var.node_group_1_max_capacity
      min_capacity     = var.node_group_1_min_capacity

      instance_types = var.node_group_1_instance_types
      k8s_labels = {
        Environment = "Dev"
      }
      additional_tags = {
        ExtraTag = "example"
      }
    }
    node_group_2 = {
      desired_capacity = var.node_group_2_desired_capacity
      max_capacity     = var.node_group_2_max_capacity
      min_capacity     = var.node_group_2_min_capacity

      instance_types = var.node_group_2_instance_types
      k8s_labels = {
        Environment = "Test"
      }
      additional_tags = {
        ExtraTag = "example"
      }
      taints = [
        {
          key    = "dedicated"
          value  = "gpuGroup"
          effect = "NO_SCHEDULE"
        }
      ]
    }
  }
}


