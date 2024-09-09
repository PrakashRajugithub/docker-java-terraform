resource "aws_ecs_cluster" "demo_cluster" {
  name = "demo-cluster"
}

resource "aws_iam_role" "ecs_task_demo_role" {
  name = "ecs-task-demo-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_demo_role_policy" {
  name = "ecs-demo-role-policy"
  role = aws_iam_role.ecs_demo_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecs:RunTask",
          "ecs:StopTask",
          "ecs:DescribeTasks",
          "ecs:DescribeServices",
          "ecs:UpdateService",
          "iam:PassRole"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}
##############################################
resource "aws_iam_role" "demo_ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "demo_ecs_task_execution_policy" {
  name = "ecsTaskExecutionPolicy"
  role = aws_iam_role.demo_ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:GetAuthorizationToken",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = "arn:aws:s3:::your-s3-bucket-name/*"
      }
    ]
  })
}



#######################################
resource "aws_iam_policy" "pass_role_policy_ecs" {
  name        = "pass-role-policy-ecs"
  description = "Allow passing roles to ECS"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "iam:PassRole",
        Resource = aws_iam_role.ecs_demo_role.arn
      }
    ]
  })
}
############################################

resource "aws_ecs_task_definition" "demo_task" {
  family                   = "demo-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn = aws_iam_role.demo_ecs_task_execution_role.arn
  task_role_arn         = aws_iam_role.ecs_task_demo_role.arn

  container_definitions = jsonencode([
    {
      name      = "demo"
      image     = "235494813694.dkr.ecr.ap-southeast-1.amazonaws.com/demo:latest"
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
  task_definition = aws_ecs_task_definition.demo_task.id
  desired_count   = 1

  network_configuration {
    subnets         = [aws_subnet.public[0].id, aws_subnet.public[0].id,]  # Replace with your VPC subnets
    security_groups = [aws_security_group.demo-sg.id]      # Replace with your security group
    # assign_public_ip = true
  }
}
