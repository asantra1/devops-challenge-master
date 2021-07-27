variable "availability_zones" {
  type = list(string)
  default = [
    "eu-west-2a",
  "eu-west-2b"]
  description = "AWS availability zones."
}

variable "region" {
  type        = string
  description = "AWS region where resources will be provisioned"
  default     = "eu-west-2"
}

variable "k8s_cluster_type" {
  type        = string
  description = "K8 cluster type where AWS Load Balancer Controller will be deployed "
  default     = "eks"
}

variable "k8s_namespace" {
  type        = string
  description = "AK8 namespace where AWS Load Balancer Controller will be deployed"
  default     = "kube-system"
}

variable "app_namespace" {
  type        = string
  description = "Application Namespace"
  default     = "game-2048"
}

# Node groups sizes - it varies in dfferent environments - dev, sit and prod
variable "node_group_1_desired_capacity" {
  type    = number
  default = 1
}

variable "node_group_1_max_capacity" {
  type    = number
  default = 2
}

variable "node_group_1_min_capacity" {
  type    = number
  default = 1
}

variable "node_group_1_instance_types" {
  type    = list(string)
  default = ["t2.small"]
}

variable "node_group_2_desired_capacity" {
  type    = number
  default = 1
}

variable "node_group_2_max_capacity" {
  type    = number
  default = 2
}

variable "node_group_2_min_capacity" {
  type    = number
  default = 1
}

variable "node_group_2_instance_types" {
  type    = list(string)
  default = ["t2.small"]
}


