resource "aws_iam_access_key" "gitlab-access-key" {
  user = aws_iam_user.gitlab-ci.id
}

resource "aws_iam_user" "gitlab-ci" {
  name = "gitlab-ci-user"
}

resource "aws_iam_user_policy" "s3-access" {
  name = "s3-access"
  user = aws_iam_user.gitlab-ci.name

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        Effect: "Allow",
        Action: [
          "s3:PutObject",
        ],
        Resource: [
          "arn:aws:s3:::${var.aws-frontend-s3-bucket}",
          "arn:aws:s3:::${var.aws-frontend-s3-bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_user_policy" "ecr-full-access" {
  name = "ecr-full-access"
  user = aws_iam_user.gitlab-ci.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement: [
      {
        Effect: "Allow",
        Action: [
          "ecr:GetRegistryPolicy",
          "ecr:DescribeRegistry",
          "ecr:GetAuthorizationToken",
          "ecr:DeleteRegistryPolicy",
          "ecr:PutRegistryPolicy",
          "ecr:PutReplicationConfiguration"
        ],
        Resource: "*"
      },
      {
        Effect: "Allow",
        Action: "ecr:*",
        Resource: "*"
      }
    ]
  })

}

resource "aws_iam_user_policy_attachment" "eks-full-access" {
  user = aws_iam_user.gitlab-ci.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_user_policy_attachment" "cloudfront-full-access" {
  user = aws_iam_user.gitlab-ci.name
  policy_arn = "arn:aws:iam::aws:policy/CloudFrontFullAccess"
}
