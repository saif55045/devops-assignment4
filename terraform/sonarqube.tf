# ─────────────────────────────────────────
# SonarQube Server — Task 4
# Deployed on a t3.small EC2 instance running
# SonarQube via Docker (with embedded H2 database)
# ─────────────────────────────────────────

# Security Group for SonarQube
resource "aws_security_group" "sonarqube_sg" {
  name        = "sonarqube-sg"
  description = "Allow SonarQube (9000) from my IP and Jenkins agent SG"
  vpc_id      = var.vpc_id

  # SonarQube UI from your IP only
  ingress {
    description = "SonarQube from my IP"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  # SonarQube from Jenkins agent SG (for scanner to report)
  ingress {
    description     = "SonarQube from Jenkins agent"
    from_port       = 9000
    to_port         = 9000
    protocol        = "tcp"
    security_groups = [var.jenkins_agent_sg_id]
  }

  # SSH from your IP
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  # All outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "sonarqube-sg" }
}

# SonarQube EC2 Instance (t3.small — SonarQube won't start on t3.micro)
resource "aws_instance" "sonarqube" {
  ami                    = var.ami_id
  instance_type          = "t3.small"
  subnet_id              = var.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.sonarqube_sg.id]
  key_name               = var.key_name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Update system
    apt-get update -y

    # Install Docker
    apt-get install -y docker.io docker-compose
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ubuntu

    # Increase vm.max_map_count (required by SonarQube / Elasticsearch)
    sysctl -w vm.max_map_count=524288
    echo "vm.max_map_count=524288" >> /etc/sysctl.conf

    # Create docker-compose file for SonarQube
    mkdir -p /opt/sonarqube
    cat > /opt/sonarqube/docker-compose.yml << 'COMPOSE'
    version: "3.8"
    services:
      sonarqube:
        image: sonarqube:lts-community
        container_name: sonarqube
        ports:
          - "9000:9000"
        environment:
          - SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true
        volumes:
          - sonarqube_data:/opt/sonarqube/data
          - sonarqube_logs:/opt/sonarqube/logs
          - sonarqube_extensions:/opt/sonarqube/extensions
        restart: unless-stopped

    volumes:
      sonarqube_data:
      sonarqube_logs:
      sonarqube_extensions:
    COMPOSE

    # Start SonarQube
    cd /opt/sonarqube
    docker-compose up -d
  EOF

  tags = { Name = "sonarqube-server" }
}
