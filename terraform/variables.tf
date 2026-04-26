variable "ami_id" {
  description = "Ubuntu 22.04 AMI ID for us-east-1"
  type        = string
}

variable "my_ip" {
  description = "Your public IP for SonarQube access restriction"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID from Assignment 3 (main-vpc)"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs from Assignment 3"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs from Assignment 3"
  type        = list(string)
}

variable "web_sg_id" {
  description = "Web server security group ID from Assignment 3"
  type        = string
}

variable "jenkins_agent_sg_id" {
  description = "Jenkins agent security group ID"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}
