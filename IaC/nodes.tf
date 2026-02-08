resource "aws_iam_role" "nodes" {
  name = "${local.env}-${local.eks_name}-eks-nodes-role"

  assume_role_policy = <<POLICY
{
    "Version" : "2012-10-17",
    "Statement" : [
      {
         "Effect" : "Allow",
         "Action" : "sts:AssumeRole",
         "Principal" : {
           "Service" : "ec2.amazonaws.com"
         }
       }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

resource "aws_eks_node_group" "general" {
  cluster_name    = aws_eks_cluster.eks.name
  version = local.eks_version
  node_group_name = "${local.env}-${local.eks_name}-eks-ng-1"
  node_role_arn   = aws_iam_role.nodes.arn
  
  subnet_ids      = [
    aws_subnet.private_zone1.id,
    aws_subnet.private_zone2.id,
    aws_subnet.private_zone3.id
  ]

# On-Demand/Spot
  capacity_type = local.purchase_option
  instance_types = [local.instances_type]

  scaling_config {
    desired_size = 3
    max_size     = 10
    min_size     = 3
  }

  update_config {
    max_unavailable = 1
  }
  
  # Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
  ]
}