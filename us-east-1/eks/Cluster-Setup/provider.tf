provider "aws" {
  default_tags {
    tags = local.tags
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.67.0"
    }
  }

  required_version = ">= 1.4.2"

}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks", "get-token",
      "--cluster-name", var.cluster_name,
      "--region", var.region
    ]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks", "get-token",
        "--cluster-name", var.cluster_name,
        "--region", var.region
      ]
    }
  }
}

# --------------------------------------------------------------------
# Helm Repository Update (Null Resource)
# --------------------------------------------------------------------
resource "null_resource" "update_helm_repo" {
  triggers = {
    cluster_endpoint = module.eks.cluster_endpoint
    cluster_ca_data  = module.eks.cluster_certificate_authority_data
  }

  provisioner "local-exec" {
    # Set HELM_CACHE_HOME and HELM_CONFIG_HOME so that the repository cache is
    # written to a persistent (and known) location.
    environment = {
      HELM_CACHE_HOME  = "C:\\Users\\himan\\.cache\\helm"
      HELM_CONFIG_HOME = "C:\\Users\\himan\\.config\\helm"
    }
    command = <<-EOT
      helm repo add argo https://argoproj.github.io/argo-helm
      helm repo add crossplane https://charts.crossplane.io/stable
      helm repo update
    EOT
  }
}