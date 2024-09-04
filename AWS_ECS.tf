resource "aws_ecs_cluster" "demo_cluster" {
  name = "Demo-cluster"
}


resource "aws_ecs_task_definition" "Demo_task" {
  family                   = "Demo-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn = aws_iam_role.codebuild_role.arn

  container_definitions = jsonencode([
    {
      name      = "Demo"
      image     = "235494813694.dkr.ecr.ap-southeast-1.amazonaws.com:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "demo_service" {
  name            = "demo-service"
  cluster         = aws_ecs_cluster.demo_cluster.id
  task_definition = aws_ecs_task_definition.Demo_task.id
  desired_count   = 1

  network_configuration {
    subnets         = [aws_subnet.public[0].id, aws_subnet.public[0].id,]  # Replace with your VPC subnets
    security_groups = [aws_security_group.demo-sg.id]      # Replace with your security group
    # assign_public_ip = true
  }
}
