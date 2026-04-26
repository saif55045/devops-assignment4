# ─── ECR Outputs ──────────────────────────
output "ecr_repository_url" {
  description = "ECR repository URL for pushing Docker images"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.app.name
}

# ─── SonarQube Outputs ───────────────────
output "sonarqube_public_ip" {
  description = "SonarQube server public IP — access at http://<IP>:9000"
  value       = aws_instance.sonarqube.public_ip
}

output "sonarqube_url" {
  description = "SonarQube URL"
  value       = "http://${aws_instance.sonarqube.public_ip}:9000"
}

# ─── Blue-Green Outputs ─────────────────
output "alb_dns_name" {
  description = "ALB DNS name — production traffic"
  value       = aws_lb.web_alb.dns_name
}

output "alb_test_url" {
  description = "ALB test listener URL — for smoke testing idle environment"
  value       = "http://${aws_lb.web_alb.dns_name}:8081"
}

output "tg_blue_arn" {
  description = "Blue target group ARN"
  value       = aws_lb_target_group.tg_blue.arn
}

output "tg_green_arn" {
  description = "Green target group ARN"
  value       = aws_lb_target_group.tg_green.arn
}

output "asg_blue_name" {
  description = "Blue Auto Scaling Group name"
  value       = aws_autoscaling_group.asg_blue.name
}

output "asg_green_name" {
  description = "Green Auto Scaling Group name"
  value       = aws_autoscaling_group.asg_green.name
}
