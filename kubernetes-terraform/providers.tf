terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.aws-region
}

data "aws_availability_zones" "available" {}

data "aws_eks_cluster_auth" "aws_iam_authenticator" {
  name = aws_eks_cluster.ascend-microservices.name
}


# Not required: currently used in conjunction with using
# icanhazip.com to determine local workstation external IP
# to open EC2 Security Group access to the Kubernetes cluster.
# See workstation-external-ip.tf for additional information.
provider "http" {}

provider "kubernetes" {
  alias = "eks"
  host = aws_eks_cluster.ascend-microservices.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.ascend-microservices.certificate_authority[0].data)
  token = data.aws_eks_cluster_auth.aws_iam_authenticator.token
}

provider "helm" {
  kubernetes {
    host = aws_eks_cluster.ascend-microservices.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.ascend-microservices.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args = ["eks", "get-token", "--cluster-name", aws_eks_cluster.ascend-microservices.name]
      command = "aws"
    }
  }
}
//
//resource "helm_release" "aws-efs-csi-driver" {
//  name = "aws-efs-csi-driver"
//  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
//  chart = "aws-efs-csi-driver"
//}
//
//resource "helm_release" "alb-ingress-controller" {
//  chart = "aws-load-balancer-controller"
//  repository = "https://aws.github.io/eks-charts"
//  name = "aws-load-balancer-controller"
//}
