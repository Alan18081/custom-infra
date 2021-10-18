resource "aws_ecs_cluster" "balder_cluster" {
  name = "balder_cluster"
}

data "template_file" "balder_task_definition_template" {
  template = file("task-def.json")
  vars = {
    REPOSITORY_URL = replace(aws_ecr_repository.balder_ecr.repository_url, "https://", "")
  }
}

resource "aws_ecs_task_definition" "balder_task_definition" {
  container_definitions = data.template_file.balder_task_definition_template.rendered
  family = "balder_app"
}

resource "aws_ecs_service" "balder_service" {
  name = "balder_service"
  cluster = aws_ecs_cluster.balder_cluster.id
  task_definition = aws_ecs_task_definition.balder_task_definition.arn
  desired_count = 2
}