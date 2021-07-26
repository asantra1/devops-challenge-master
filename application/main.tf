
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
  }
}

variable "namespace" {
  type        = string
  description = "Application namespace name"
  default     = "game-2048"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# Create the namespace
resource "kubernetes_namespace" "eks-namespace" {
  metadata {
    name = var.namespace
  }
}

# Deploy the helm chart
resource "helm_release" "app-2048" {
  name       = "app-2048"
  chart      = "../charts"
  namespace = var.namespace
}






