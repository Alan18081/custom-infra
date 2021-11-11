#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#

//
//{
//"Effect": "Allow",
//"Principal": {
//"Federated": "${var.aws_region}"
//}
//}

resource "aws_iam_policy" "ascend-efs-csi-driver_policy" {
  name = "AmazonEKS_EFS_CSI_Driver_Policy"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:DescribeAccessPoints",
        "elasticfilesystem:DescribeFileSystems"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:CreateAccessPoint"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "aws:RequestTag/efs.csi.aws.com/cluster": "true"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "elasticfilesystem:DeleteAccessPoint",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/efs.csi.aws.com/cluster": "true"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role" "ascend-microservices-cluster" {
  name = var.cluster-name

  assume_role_policy = <<POLICY
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
POLICY
}

resource "aws_iam_role" "ascend_efs_driver_role" {
  name = "AmazonEKS_EFS_CSI_DriverRole"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${var.aws-account-id}:oidc-provider/${replace(aws_eks_cluster.ascend-microservices.identity.0.oidc.0.issuer, "https://", "")}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(aws_eks_cluster.ascend-microservices.identity.0.oidc.0.issuer, "https://", "")}:sub": "system:serviceaccount:kube-system:efs-csi-controller-sa"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "efs-csi-role_driver_attachment" {
  policy_arn = aws_iam_policy.ascend-efs-csi-driver_policy.arn
  role = "AmazonEKS_EFS_CSI_DriverRole"

  depends_on = [aws_iam_policy.ascend-efs-csi-driver_policy, aws_iam_role.ascend_efs_driver_role]
}

//,
//{
//"Effect": "Allow",
//"Principal": {
//"Federated": "${aws_iam_openid_connect_provider.demo.arn}"
//},
//"Action": "sts:AssumeRoleWithWebIdentity",
//"Condition": {
//"StringEquals": {
//"${replace(aws_iam_openid_connect_provider.demo.url, "https://", "")}:sub": ["system:serviceaccount:kube-system:aws-node"]
//}
//}
//}

resource "aws_iam_role_policy_attachment" "ascend-microservices-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.ascend-microservices-cluster.name
}

resource "aws_iam_role_policy_attachment" "ascend-microservices-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.ascend-microservices-cluster.name
}

resource "aws_security_group" "ascend-microservices-cluster" {
  name        = "ascend-microservices-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.ascend-microservices.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-demo"
  }
}

resource "aws_security_group_rule" "ascend-microservices-cluster-ingress-workstation-https" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.ascend-microservices-cluster.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "ascend-microservices" {
  name     = var.cluster-name
  role_arn = aws_iam_role.ascend-microservices-cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.ascend-microservices-cluster.id]
    subnet_ids         = aws_subnet.ascend-microservices[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.ascend-microservices-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.ascend-microservices-cluster-AmazonEKSVPCResourceController,
  ]

}


//data "tls_certificate" "demo" {
//  url = aws_eks_cluster.demo.identity[0].oidc
//}

//data "aws_iam_policy_document" "demo_assume_role_policy" {
//  statement {
//    actions = ["sts:AssumeRoleWithWebIdentity"]
//    effect = "Allow"
//
//    condition {
//      test = "StringEquals"
//      values = ["${replace(aws_iam_openid_connect_provider.demo.url, "https://", "")}:sub"]
//      variable = "${replace(aws_iam_openid_connect_provider.demo.url, "https://", "")}:sub"
//    }
//
//    principals {
//      identifiers = [aws_iam_openid_connect_provider.demo.arn]
//      type        = "Federated"
//    }
//  }
//}
//
//resource "aws_iam_role" "openid_demo" {
//  assume_role_policy = data.aws_iam_policy_document.demo_assume_role_policy.json
//  name               = "openid_demo"
//}

data "tls_certificate" "ascend-microservices-cluster" {
  url = aws_eks_cluster.ascend-microservices.identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "ascend-microservices-cluster" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.ascend-microservices-cluster.certificates.0.sha1_fingerprint]
  url = aws_eks_cluster.ascend-microservices.identity.0.oidc.0.issuer
}