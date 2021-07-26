terraform {
  required_version = ">=0.15"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    tls = {
        source = "hashicorp/tls"
        version = "~> 3.1.0"
    }
  }
}


provider "kubernetes" {
  alias = "eks"
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "aws" {
  region = "eu-west-2"
}

data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket = "asantra1-terraform-state"
    key    = "global/s3/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "aws_eks_cluster" "eks_cluster" {
  name = data.terraform_remote_state.cluster.outputs.cluster_name
}

output "endpoint" {
  value = data.aws_eks_cluster.eks_cluster.endpoint
}

output "ca" {
  value = data.aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

# Only available on Kubernetes version 1.13 and 1.14 clusters created or upgraded on or after September 3, 2019.
output "identity-oidc-issuer" {
  value = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

output "cluster-name" {
  value = data.aws_eks_cluster.eks_cluster.name
}

data "tls_certificate" "cluster_tls" {
  url = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

### OIDC config
resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster_tls.certificates.0.sha1_fingerprint]
  url             = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

# IAM policy creation
resource "aws_iam_policy" "load-balancer-policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "AWS LoadBalancer Controller IAM Policy"
  policy = "${file("iam_policy.json")}"
  
}

module "alb_ingress_controller" {
  source  = "iplabs/alb-ingress-controller/kubernetes"
  version = "3.1.0"

  providers = {
    kubernetes = kubernetes.eks
  }

  k8s_cluster_type = "eks"
  k8s_namespace    = "kube-system"

  aws_region_name  = "eu-west-2"
  k8s_cluster_name = data.aws_eks_cluster.eks_cluster.name
}