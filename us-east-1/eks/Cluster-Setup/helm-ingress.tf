resource "helm_release" "alb_ingress" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.6.1" # specify the version you want
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = true
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "vpcId"
    value = aws_vpc.eks-vpc.id
  }

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.alb_ingress_controller_iam_role.arn
  }

  depends_on = [
    aws_eks_cluster.ecloudworx-eks,
    aws_iam_role.alb_ingress_controller_iam_role,
    aws_iam_role_policy_attachment.alb_controller_iam_role_policy_attach
  ]
}