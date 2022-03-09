resource "aws_iam_role" "eks_cluster" {
  name = "eks-demo-cluster"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_vpc" "demo_vpc" {
  cidr_block = "192.168.0.0/16"
  
  tags = {
      Name = "demovpc"
      Project = "demo"
    }
}

resource "aws_subnet" "demo_private_a" {
  vpc_id = "${aws_vpc.demo_vpc.id}"
  availability_zone = "us-east-2a"
  cidr_block = "192.168.3.0/24"
  
  tags = {
      Name = "demo_private_a"
	  Project = "demo"
  }
}

resource "aws_subnet" "demo_private_b" {
  vpc_id = "${aws_vpc.demo_vpc.id}"
  availability_zone = "us-east-2b"
  cidr_block = "192.168.4.0/24"
  
  tags = {
      Name = "demo_private_b"
	  Project = "demo"
  }
}

resource "aws_eks_cluster" "aws_eks" {
  name     = "eks_demo_cluster"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = ["demo_private_a", "demo_private_b""]
  }

  tags = {
    Name = "EKS_DEMO"
  }
}

resource "aws_iam_role" "eks_nodes" {
  name = "eks-node-group-demo"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_eks_node_group" "node" {
  cluster_name    = aws_eks_cluster.aws_eks.name
  node_group_name = "node_demo"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = ["demo_private_a", "demo_private_b"]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}