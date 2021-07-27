# Get thumbprints from OIDC issuer
data "tls_certificate" "cluster_tls" {
  url = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}


### OIDC provider creation
resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster_tls.certificates.0.sha1_fingerprint]
  url             = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

# Deploy an AWS Load Balancer Controller to the EKS cluster 
# Lablabs terraform-aws-eks-alb-ingress is used here
module "alb_ingress_controller" {
  source  = "iplabs/alb-ingress-controller/kubernetes"
  version = "3.1.0"

  k8s_cluster_type = var.k8s_cluster_type
  k8s_namespace    = var.k8s_namespace

  aws_region_name  = var.region
  k8s_cluster_name = data.aws_eks_cluster.eks_cluster.name
}

# Create the application namespaces to be used by development team
# Create the namespace
resource "kubernetes_namespace" "eks_namespace" {
  metadata {
    name = var.app_namespace
  }
}