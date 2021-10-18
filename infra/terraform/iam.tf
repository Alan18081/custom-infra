data "aws_iam_policy_document" "balder_ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "balder_ecs_agent" {
  name = "balder_ecs_agent"
  assume_role_policy = data.aws_iam_policy_document.balder_ecs_agent.json
}

resource "aws_iam_role_policy_attachment" "balder_ecs_agent" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceForEC2Role"
  role = aws_iam_role.balder_ecs_agent
}

resource "aws_iam_instance_profile" "balder_ecs_agent" {
  name = "balder_ecs_agent"
  role = aws_iam_role.balder_ecs_agent.name
}