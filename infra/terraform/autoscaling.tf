resource "aws_launch_configuration" "balder_launch_config" {
  image_id = var.ecs_ami_image
  instance_type = var.ecs_ec2_instance_type
  iam_instance_profile = aws_iam_instance_profile.balder_ecs_agent.name
  security_groups = [aws_security_group.balder_ecs_sg.id]
}

resource "aws_autoscaling_group" "balder_asg" {
  name = "balder_asg"
  vpc_zone_identifier = [aws_subnet.balder_public_1.id]
  launch_configuration = aws_launch_configuration.balder_launch_config.name

  desired_capacity = 2
  max_size = 10
  min_size = 1

  health_check_grace_period = 300
  health_check_type = "EC2"
}