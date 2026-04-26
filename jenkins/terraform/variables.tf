variable "ami_id" {
  description = "Ubuntu 22.04 AMI ID for us-east-1"
  type        = string
}

variable "my_ip" {
  description = "Your public IP address for SSH and Jenkins UI access restriction"
  type        = string
}
