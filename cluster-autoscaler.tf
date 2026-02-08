resource "aws_iam_role" "cluster_autoscaler" {
  name = "${aws_eks_cluster.eks.name}-cluster-autoscaler"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name   = "AWSClusterAutoscaler"
  policy = file("./iam/AWSClusterAutoscaler.json")
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  role       = aws_iam_role.cluster_autoscaler.name
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
}

resource "aws_eks_pod_identity_association" "cluster_autoscaler" {
  cluster_name    = aws_eks_cluster.eks.name
  namespace       = "kube-system"
  service_account = "aws-cluster-autoscaler-sa"
  role_arn        = aws_iam_role.cluster_autoscaler.arn
}

resource "helm_release" "cluster_autoscaler" {
  name       = "autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.37.0"

  set = [
    {
      name  = "rbac.serviceAccount.name"
      value = "aws-cluster-autoscaler-sa"
    },
    {
      name  = "autoDiscovery.clusterName"
      value = aws_eks_cluster.eks.name
    },
    {
      name  = "awsRegion"
      value = local.region
    }
  ]


  depends_on = [helm_release.metrics_server ]
}
