#############################
# EKS Add-ons
#############################

# Metrics Server (kube-metrics-server)
resource "aws_eks_addon" "kube_metrics_server" {
  cluster_name                = var.cluster_name  # Reference your EKS cluster
  addon_name                  = "metrics-server"
  addon_version               = "v0.7.2-eksbuild.2"
  resolve_conflicts_on_create = "OVERWRITE"       # Automatically resolves version conflicts
}

# Prometheus Node Exporter
resource "aws_eks_addon" "prometheus_node_exporter" {
  cluster_name                = var.cluster_name
  addon_name                  = "prometheus-node-exporter"
  addon_version               = "v1.9.0-eksbuild.3"
  resolve_conflicts_on_create = "OVERWRITE"
}

# Kube Proxy
resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = var.cluster_name
  addon_name                  = "kube-proxy"
  addon_version               = "v1.31.2-eksbuild.3"  # Update to match your cluster version
  resolve_conflicts_on_create = "OVERWRITE"
}

# CoreDNS
resource "aws_eks_addon" "coredns" {
  cluster_name                = var.cluster_name
  addon_name                  = "coredns"
  addon_version               = "v1.11.3-eksbuild.1"  # Update to match your cluster version
  resolve_conflicts_on_create = "OVERWRITE"
}

# VPC CNI (with attached IAM role)
resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = var.cluster_name
  addon_name                  = "vpc-cni"
  addon_version               = "v1.19.0-eksbuild.1"  # Update to match your cluster version
  resolve_conflicts_on_create = "OVERWRITE"
  service_account_role_arn    = aws_iam_role.AmazonEKSPodIdentityAmazonVPCCNIRole.arn
}

#############################
# IAM Roles and Policy Attachments
#############################

# IAM Role for VPC CNI
resource "aws_iam_role" "AmazonEKSPodIdentityAmazonVPCCNIRole" {
  name = "AmazonEKSPodIdentityAmazonVPCCNIRole"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = ["pods.eks.amazonaws.com"]
        },
        Action    = ["sts:AssumeRole", "sts:TagSession"]
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "AmazonEKS_CNI_Policy" {
  name       = "AmazonEKS_CNI_Policy"
  roles      = [aws_iam_role.AmazonEKSPodIdentityAmazonVPCCNIRole.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# IAM Role for ADOT (Prometheus Metrics collection)
resource "aws_iam_role" "AmazonEKSPodIdentityADOT_adot_col_prom_metrics_Role" {
  name = "AmazonEKSPodIdentityADOT-adot-col-prom-metrics-Role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = ["pods.eks.amazonaws.com"] },
        Action    = ["sts:AssumeRole", "sts:TagSession"]
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "AmazonPrometheusRemoteWriteAccess" {
  name       = "AmazonPrometheusRemoteWriteAccess"
  roles      = [aws_iam_role.AmazonEKSPodIdentityADOT_adot_col_prom_metrics_Role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess"
}

resource "aws_iam_policy_attachment" "CloudWatchAgentServerPolicy" {
  name       = "CloudWatchAgentServerPolicy"
  roles      = [aws_iam_role.AmazonEKSPodIdentityADOT_adot_col_prom_metrics_Role.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# IAM Role for ADOT (OTLP Ingest)
resource "aws_iam_role" "AmazonEKSPodIdentityADOT_adot_col_otlp_ingest_Role" {
  name = "AmazonEKSPodIdentityADOT-adot-col-otlp-ingest-Role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = ["pods.eks.amazonaws.com"] },
        Action    = ["sts:AssumeRole", "sts:TagSession"]
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "AWSXrayWriteOnlyAccess" {
  name       = "AWSXrayWriteOnlyAccess"
  roles      = [aws_iam_role.AmazonEKSPodIdentityADOT_adot_col_otlp_ingest_Role.name]
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

# IAM Role for ADOT (Container Logs)
resource "aws_iam_role" "AmazonEKSPodIdentityADOT_adot_col_container_logs_Role" {
  name = "AmazonEKSPodIdentityADOT-adot-col-container-logs-Role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = ["pods.eks.amazonaws.com"] },
        Action    = ["sts:AssumeRole", "sts:TagSession"]
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "CloudWatchAgentServerPolicy_container_logs" {
  name       = "CloudWatchAgentServerPolicy_container_logs"
  roles      = [aws_iam_role.AmazonEKSPodIdentityADOT_adot_col_container_logs_Role.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

#############################
# App Mesh Controller Installation via Helm
#############################

resource "helm_release" "appmesh_controller" {
  name             = "appmesh-controller"
  namespace        = "appmesh-system"
  create_namespace = true

  repository = "https://aws.github.io/eks-charts"
  chart      = "appmesh-controller"
  version    = "1.8.0" # Specify the desired version

  set {
    name  = "region"
    value = "us-east-1" # Replace with your AWS region if needed
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "appmesh-controller"
  }
}

#############################
# Locals and Namespace Definitions
#############################

locals {
  tags                 = { Environment = "production" }
  argocd_namespace     = "argocd"
  gitops_namespace     = "gitops-bridge"
  crossplane_namespace = "crossplane-system"
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = local.argocd_namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "kubernetes_namespace" "gitops_bridge" {
  metadata {
    name = local.gitops_namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "kubernetes_namespace" "crossplane" {
  metadata {
    name = local.crossplane_namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

#############################
# Argo CD Installation via Helm
#############################

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.46.8"
  namespace  = local.argocd_namespace

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  depends_on = [
    module.eks,  // Ensure your EKS cluster module is applied first
    kubernetes_namespace.argocd
  ]
}

#############################
# GitOps Bridge Installation via Helm
#############################

resource "helm_release" "gitops_bridge" {
  name       = "gitops-bridge"
  repository = "https://gitops-bridge.github.io/gitops-bridge-helm"
  chart      = "gitops-bridge"
  version    = "0.1.0"
  namespace  = local.gitops_namespace

  depends_on = [
    helm_release.argocd,
    kubernetes_namespace.gitops_bridge
  ]
}

#############################
# Crossplane Installation via Helm
#############################

resource "helm_release" "crossplane" {
  name             = "crossplane"
  repository       = "https://charts.crossplane.io/stable"
  chart            = "crossplane"
  version          = "1.12.0"
  namespace        = local.crossplane_namespace
  create_namespace = false

  depends_on = [
    kubernetes_namespace.crossplane
  ]
}
