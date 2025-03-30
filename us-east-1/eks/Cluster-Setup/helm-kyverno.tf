resource "helm_release" "kyverno" {
    name       = "kyverno"
    namespace  = "kyverno"
    chart      = "kyverno/kyverno"
    repository = "https://kyverno.github.io/kyverno/"
    version    = "1.13.4" # Replace with the desired version

    create_namespace = true

    values = [
        <<EOF
replicaCount: 2
resources:
    limits:
        cpu: 500m
        memory: 512Mi
    requests:
        cpu: 250m
        memory: 256Mi
EOF
    ]

    depends_on = [
    aws_eks_cluster.ecloudworx-eks,
    aws_iam_role.alb_ingress_controller_iam_role,
    aws_iam_role_policy_attachment.alb_controller_iam_role_policy_attach
  ]    
}