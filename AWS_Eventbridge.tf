resource "aws_cloudwatch_event_rule" "github_codebuild_trigger" {
  name        = "github-codebuild-trigger"
  description = "Trigger CodeBuild on GitHub repository changes"
  event_pattern = jsonencode({
    "source": [
      "github"
    ],
    "detail-type": [
      "Github Repository State Change"
    ],
    "detail": {
      "event": [
        "referenceCreated",
        "referenceUpdated"
      ],
      "repositoryName": [
        "docker-java-terraform"
      ],
      "referenceType": [
        "branch"
      ],
      "referenceName": [
        "main"
      ]
    }
  })
}
########################################
resource "aws_iam_role" "eventbridge_codebuild_role" {
  name = "eventbridge-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
################################
resource "aws_cloudwatch_event_target" "codebuild_target" {
  rule      = aws_cloudwatch_event_rule.github_codebuild_trigger.name
  target_id = "codebuild"
  arn       = aws_codebuild_project.build_Demo.arn
  role_arn  = aws_iam_role.eventbridge_codebuild_role.arn
}

resource "aws_iam_role_policy" "allow_eventbridge_trigger" {
  name = "allow-eventbridge-trigger"
  role = aws_iam_role.eventbridge_codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codebuild:StartBuild"
        ]
        Resource = aws_codebuild_project.build_Demo.arn
      }
    ]
  })
}
