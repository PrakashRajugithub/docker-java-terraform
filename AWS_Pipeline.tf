###############################
resource "aws_iam_role" "demo_codepipeline_role" {
  name = "codepipeline-demo-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codepipeline.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "demo_codepipeline_policy" {
  name = "CodePipelinePolicy-demo"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::your-pipeline-artifact-bucket",
          "arn:aws:s3:::your-pipeline-artifact-bucket/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds",
          "codebuild:BatchGetProjects"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecs:DescribeServices",
          "ecs:UpdateService",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "iam:PassRole"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "demo_codepipeline_policy_attachment" {
  role       = aws_iam_role.demo_codepipeline_role.name
  policy_arn = aws_iam_policy.demo_codepipeline_policy.arn
}


################################

resource "aws_codepipeline" "demo_pipeline" {
  name = "demo-pipeline"
  role_arn = aws_iam_role.demo_codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.BuildArtifacts.bucket
    type     = "S3"
  }

#   stage {
#     name = "Source"

#     action {
#       name             = "Source"
#       category         = "Source"
#       owner            = "AWS"
#       provider         = "GitHub"
#       version          = "1"
#       output_artifacts = ["source_output"]

#       configuration = {
#         Owner      = "your-github-username"
#         Repo       = "your-repo"
#         Branch     = "main"
#         OAuthToken = var.github_oauth_token
#       }
#     }
#   }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = []
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.build_Demo.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "ECS"
      input_artifacts  = ["build_output"]
      version          = "1"

      configuration = {
        ClusterName      = aws_ecs_cluster.demo_cluster.id
        ServiceName      = aws_ecs_service.demo_service.name
        FileName         = "imagedefinitions.json"
      }
    }
  }
}
