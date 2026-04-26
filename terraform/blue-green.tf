# ─────────────────────────────────────────
# Blue-Green Deployment Infrastructure — Task 7
# Two Auto Scaling Groups behind one ALB with
# separate target groups for traffic switching
# ─────────────────────────────────────────

# ─── ALB Security Group ───────────────────
resource "aws_security_group" "alb_sg" {
  name        = "a4-alb-sg"
  description = "Allow HTTP inbound to ALB"
  vpc_id      = var.vpc_id

  # Production traffic (port 80)
  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Test listener (port 8081) — for smoke testing idle environment
  ingress {
    description = "Test listener for smoke tests"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "a4-alb-sg" }
}

# ─── Application Load Balancer ────────────
resource "aws_lb" "web_alb" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.alb_sg.id]

  tags = { Name = "web-alb" }
}

# ─── Target Group: BLUE ──────────────────
resource "aws_lb_target_group" "tg_blue" {
  name     = "tg-blue"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    port                = 3000
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
    matcher             = "200"
  }

  tags = { Name = "tg-blue" }
}

# ─── Target Group: GREEN ─────────────────
resource "aws_lb_target_group" "tg_green" {
  name     = "tg-green"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    port                = 3000
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
    matcher             = "200"
  }

  tags = { Name = "tg-green" }
}

# ─── Production Listener (Port 80) ───────
# Initially forwards to BLUE target group
resource "aws_lb_listener" "production" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_blue.arn
  }
}

# ─── Test Listener (Port 8081) ────────────
# Used for smoke testing the idle environment
# This listener always points to the IDLE target group
# (managed by the Jenkins pipeline via AWS CLI)
resource "aws_lb_listener" "test" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 8081
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_green.arn
  }
}

# ─── Launch Template: BLUE ────────────────
resource "aws_launch_template" "lt_blue" {
  name_prefix   = "lt-blue-"
  image_id      = var.ami_id
  instance_type = "t3.micro"
  key_name      = var.key_name

  vpc_security_group_ids = [var.web_sg_id]

  user_data = base64encode(<<-USERDATA
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker

    # Pull and run the application from ECR
    # (The Jenkins pipeline updates the launch template version with the correct image)
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    echo "Blue environment - Instance: $INSTANCE_ID" > /tmp/env-info.txt
  USERDATA
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "asg-blue-instance"
      Environment = "blue"
    }
  }
}

# ─── Launch Template: GREEN ───────────────
resource "aws_launch_template" "lt_green" {
  name_prefix   = "lt-green-"
  image_id      = var.ami_id
  instance_type = "t3.micro"
  key_name      = var.key_name

  vpc_security_group_ids = [var.web_sg_id]

  user_data = base64encode(<<-USERDATA
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker

    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    echo "Green environment - Instance: $INSTANCE_ID" > /tmp/env-info.txt
  USERDATA
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "asg-green-instance"
      Environment = "green"
    }
  }
}

# ─── Auto Scaling Group: BLUE ────────────
resource "aws_autoscaling_group" "asg_blue" {
  name                = "asg-blue"
  vpc_zone_identifier = var.public_subnet_ids
  min_size            = 1
  max_size            = 3
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.lt_blue.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg_blue.arn]

  tag {
    key                 = "Name"
    value               = "asg-blue-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "blue"
    propagate_at_launch = true
  }
}

# ─── Auto Scaling Group: GREEN ───────────
resource "aws_autoscaling_group" "asg_green" {
  name                = "asg-green"
  vpc_zone_identifier = var.public_subnet_ids
  min_size            = 1
  max_size            = 3
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.lt_green.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg_green.arn]

  tag {
    key                 = "Name"
    value               = "asg-green-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "green"
    propagate_at_launch = true
  }
}
