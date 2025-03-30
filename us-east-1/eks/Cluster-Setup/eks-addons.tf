# Metrics Server (kube-metrics-server)
resource "aws_eks_addon" "kube_metrics_server" {
  cluster_name      = aws_eks_cluster.ecloudworx-eks.name  # Reference your EKS cluster
  addon_name        = "metrics-server"
  addon_version     = "v0.7.2-eksbuild.2"
  resolve_conflicts_on_create = "OVERWRITE"  # Automatically resolves version conflicts
}

# Prometheus Node Exporter
resource "aws_eks_addon" "prometheus_node_exporter" {
  cluster_name      = aws_eks_cluster.ecloudworx-eks.name
  addon_name        = "prometheus-node-exporter"
  addon_version     = "v1.9.0-eksbuild.3"
  resolve_conflicts_on_create = "OVERWRITE"
}

# Kube Proxy (commonly needed with metrics addons)
resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = aws_eks_cluster.ecloudworx-eks.name
  addon_name        = "kube-proxy"
  addon_version     = "v1.31.2-eksbuild.3"  # Update to match your cluster version
  resolve_conflicts_on_create = "OVERWRITE"
}

# CoreDNS (often needed for cluster operations)
resource "aws_eks_addon" "coredns" {
  cluster_name      = aws_eks_cluster.ecloudworx-eks.name
  addon_name        = "coredns"
  addon_version     = "v1.11.3-eksbuild.1"  # Update to match your cluster version
  resolve_conflicts_on_create = "OVERWRITE"
}

# VPC CNI (networking requirement)
resource "aws_eks_addon" "vpc_cni" {
  cluster_name      = aws_eks_cluster.ecloudworx-eks.name
  addon_name        = "vpc-cni"
  addon_version     = "v1.19.0-eksbuild.1"  # Update to match your cluster version
  resolve_conflicts_on_create = "OVERWRITE"
  # This one might need IAM permissions:
  service_account_role_arn = aws_iam_role.AmazonEKSPodIdentityAmazonVPCCNIRole.arn
}

resource "aws_iam_role" "AmazonEKSPodIdentityAmazonVPCCNIRole" {
  name = "AmazonEKSPodIdentityAmazonVPCCNIRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = ["pods.eks.amazonaws.com"]
        }
        Action = ["sts:AssumeRole", "sts:TagSession"]
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "AmazonEKS_CNI_Policy" {
  name       = "AmazonEKS_CNI_Policy"
  roles      = [aws_iam_role.AmazonEKSPodIdentityAmazonVPCCNIRole.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role" "AmazonEKSPodIdentityADOT_adot_col_prom_metrics_Role" {
  name = "AmazonEKSPodIdentityADOT-adot-col-prom-metrics-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = ["pods.eks.amazonaws.com"]
        }
        Action = ["sts:AssumeRole", "sts:TagSession"]
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

resource "aws_iam_role" "AmazonEKSPodIdentityADOT_adot_col_otlp_ingest_Role" {
  name = "AmazonEKSPodIdentityADOT-adot-col-otlp-ingest-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = ["pods.eks.amazonaws.com"]
        }
        Action = ["sts:AssumeRole", "sts:TagSession"]
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "AWSXrayWriteOnlyAccess" {
  name       = "AWSXrayWriteOnlyAccess"
  roles      = [aws_iam_role.AmazonEKSPodIdentityADOT_adot_col_otlp_ingest_Role.name]
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

resource "aws_iam_role" "AmazonEKSPodIdentityADOT_adot_col_container_logs_Role" {
  name = "AmazonEKSPodIdentityADOT-adot-col-container-logs-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = ["pods.eks.amazonaws.com"]
        }
        Action = ["sts:AssumeRole", "sts:TagSession"]
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "CloudWatchAgentServerPolicy_container_logs" {
  name       = "CloudWatchAgentServerPolicy_container_logs"
  roles      = [aws_iam_role.AmazonEKSPodIdentityADOT_adot_col_container_logs_Role.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
