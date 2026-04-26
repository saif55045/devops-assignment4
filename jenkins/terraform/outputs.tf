output "jenkins_controller_public_ip" {
  description = "Public IP of the Jenkins controller — access at http://<IP>:8080"
  value       = aws_instance.jenkins_controller.public_ip
}

output "jenkins_controller_public_dns" {
  description = "Public DNS of the Jenkins controller"
  value       = aws_instance.jenkins_controller.public_dns
}

output "jenkins_agent_private_ip" {
  description = "Private IP of the Jenkins agent — use this when adding agent in Jenkins UI"
  value       = aws_instance.jenkins_agent.private_ip
}

output "jenkins_key_name" {
  description = "Name of the SSH key pair"
  value       = aws_key_pair.jenkins.key_name
}
