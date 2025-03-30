resource "helm_release" "argocd" {
    name       = "argocd"
    namespace  = "argocd"
    chart      = "argo-cd"
    repository = "https://argoproj.github.io/argo-helm"
    version    = "2.14.8"

    create_namespace = true

    values = [
        <<EOF
server:
    service:
        type: LoadBalancer
EOF
    ]

depends_on = [
    aws_eks_cluster.ecloudworx-eks,
    aws_iam_role.alb_ingress_controller_iam_role,
    aws_iam_role_policy_attachment.alb_controller_iam_role_policy_attach
  ]    
}