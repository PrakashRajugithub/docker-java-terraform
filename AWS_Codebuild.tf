# provider "aws" {
#   region = "ap-southeast-1"
# }

resource "aws_s3_bucket" "BuildArtifacts" {
    bucket = "demoartifacts1"
  
}
# Create ECR Repository
resource "aws_ecr_repository" "demo" {
  name = "demo"
}

# Create IAM Role for CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-Demo-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  }
  
  resource "aws_iam_role_policy_attachment" "CodebuildECRpolicy" {
    role = aws_iam_role.codebuild_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
    }

resource "aws_iam_role_policy" "codebuild_cloudwatch_policy" {
  name = "codebuild-logs-policy"
  role = aws_iam_role.codebuild_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = [
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/*",
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/*:log-stream:*"
        ]
      },
      {
        Action   = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/demo"
      }
    ]
  })
}



resource "aws_codebuild_project" "build_Demo" {
  name          = "build-Demo"
  service_role  = aws_iam_role.codebuild_role.arn

  source {
    type            = "GITHUB"
    location        = "https://github.com/PrakashRajugithub/docker-java-terraform.git"
    buildspec       = "buildspec.yml"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true

     environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = "ap-southeast-1"
    }
    environment_variable {
      name  = "ECR_REPO"
      value = aws_ecr_repository.demo.repository_url
    }

  }

  cache {
    type = "S3"
    location = aws_s3_bucket.BuildArtifacts.bucket
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }
}
