 # Declare variables 
variable "namespace" {
  type        = string
  description = "Application namespace name"
  default     = "game-2048"
}

# Deploy the helm chart
resource "helm_release" "app-2048" {
  name      = "app-2048"
  chart     = "../charts"
  namespace = var.namespace
}






