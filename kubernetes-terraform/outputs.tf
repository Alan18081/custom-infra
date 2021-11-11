#
# Outputs
#

locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.ascend-microservices-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH

  kubeconfig = <<KUBECONFIG


apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.ascend-microservices.endpoint}
    certificate-authority-data: ${aws_eks_cluster.ascend-microservices.certificate_authority[0].data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.cluster-name}"
KUBECONFIG
}

output "config_map_aws_auth" {
  value = local.config_map_aws_auth
}

output "kubeconfig" {
  value = local.kubeconfig
}

output "aws_ecr_url" {
  value = aws_ecr_repository.audit-service-ecr.repository_url
}

output "cluster_name" {
  value = var.cluster-name
}

output "region" {
  value = var.aws-region
}

output "aws_efs_id" {
  value = aws_efs_file_system.audit_files_system.id
}

output "gitlab_ci_user_access_key" {
  value = aws_iam_access_key.gitlab-access-key.id
}

output "gitlab_ci_user_access_secret" {
  value = aws_iam_access_key.gitlab-access-key.secret
  sensitive = true
}

output "oid" {
  value = aws_eks_cluster.ascend-microservices.identity.0.oidc.0.issuer
}