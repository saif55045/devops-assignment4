# ─────────────────────────────────────────
# AWS ECR Repository — Task 5
# Private container registry for the sample app
# ─────────────────────────────────────────

resource "aws_ecr_repository" "app" {
  name                 = "devops-sample-app"
  image_tag_mutability = "MUTABLE"

  # Enable image scanning on push
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "devops-sample-app"
    Environment = "assignment-4"
  }
}

# ─── Lifecycle Policy ──────────────────────
# Keep 10 most recent images, expire untagged after 7 days
resource "aws_ecr_lifecycle_policy" "app_lifecycle" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after 7 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep only the 10 most recent tagged images"
        selection = {
          tagStatus   = "tagged"
          tagPrefixList = ["v", "main", "dev"]
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
