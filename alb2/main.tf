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

output "iam_policy_arn" {
  value = aws_iam_policy.load-balancer-policy.arn
}

output "oidc_provider" {
  value = split("oidc-provider/", "${aws_iam_openid_connect_provider.cluster.arn}")[1]
}

resource "aws_iam_role" "role" {
  name = "AmazonEKSLoadBalancerControllerRole"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${aws_iam_openid_connect_provider.cluster.arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${output.oidc_provider.value}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "sa-attach" {
  name       = "sa-attachment"
  roles      = [aws_iam_role.role.name]
  policy_arn = aws_iam_policy.load-balancer-policy.arn
}

resource "kubernetes_service_account" "aws-load-balancer-controller" {
  metadata {
    name = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
        "app.kubernetes.io/component" = "controller"
        "app.kubernetes.io/name": "aws-load-balancer-controller"
    }
    annotations = {
        "eks.amazonaws.com/role-arn" = "${aws_iam_role.role.arn}"
    }
  }
}

resource "aws_iam_policy" "addn-load-balancer-policy" {
  name        = "AWSLoadBalancerControllerAdditionalIAMPolicy"
  description = "AWS LoadBalancer Controller IAM Policy"
  policy = "${file("iam_policy_v1_to_v2_additional.json")}"


resource "aws_iam_policy_attachment" "addn-attach" {
  name       = "addn-attachment"
  roles      = [aws_iam_role.role.name]
  policy_arn = aws_iam_policy.addn-load-balancer-policy.arn
}








