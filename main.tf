locals {
  ecr_repository_name = "hello-world"
  service_name        = "hello-world"
  service_port        = 8000
  service_release_tag = "latest"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_ecr_repository" "ecr_repository" {
  name = local.ecr_repository_name
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "ecr_lifecycle_policy" {
  repository = aws_ecr_repository.ecr_repository.name
  policy     = jsonencode({
    "rules" : [
      {
        "rulePriority" : 1,
        "description" : "Expire untagged images older than 14 days",
        "selection" : {
          "tagStatus" : "untagged",
          "countType" : "sinceImagePushed",
          "countUnit" : "days",
          "countNumber" : 14
        },
        "action" : {
          "type" : "expire"
        }
      }
    ]
  })
}

resource "aws_iam_role" "runner_role" {
  name               = "${local.service_name}-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "runner_role_policy_attachment" {
  role       = aws_iam_role.runner_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

resource "aws_apprunner_service" "runner_service" {
  service_name = local.service_name
  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.runner_role.arn
    }
    image_repository {
      image_identifier      = "${aws_ecr_repository.ecr_repository.repository_url}:${local.service_release_tag}"
      image_repository_type = "ECR"
      image_configuration {
        port = local.service_port
      }
    }
  }
}

output "service_url" {
  value = aws_apprunner_service.runner_service.service_url
}