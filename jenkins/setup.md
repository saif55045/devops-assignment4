# Jenkins Controller & Agent Setup Guide

## Overview

This document describes the step-by-step setup of the Jenkins controller (master) and a build agent on separate EC2 instances within the VPC from Assignment 3.

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                    VPC (10.0.0.0/16)                │
│                                                     │
│  ┌──────────────────────┐   ┌────────────────────┐  │
│  │   Public Subnet 1    │   │  Private Subnet 1  │  │
│  │   10.0.1.0/24        │   │  10.0.10.0/24      │  │
│  │                      │   │                    │  │
│  │  ┌────────────────┐  │   │  ┌──────────────┐  │  │
│  │  │  Jenkins        │  │   │  │ Jenkins      │  │  │
│  │  │  Controller     │──│───│──│ Agent        │  │  │
│  │  │  (Port 8080)    │  │   │  │ (linux-agent)│  │  │
│  │  └────────────────┘  │   │  └──────────────┘  │  │
│  └──────────────────────┘   └────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

---

## Step 1: Provision EC2 Instances with Terraform

```bash
cd jenkins/terraform
terraform init
terraform plan
terraform apply
```

This creates:
- **Jenkins Controller** — `t3.medium` in public subnet, ports 8080 (Jenkins UI) and 22 (SSH) open
- **Jenkins Agent** — `t3.medium` in private subnet, SSH from controller only
- Security groups, IAM roles, and SSH key pair

---

## Step 2: Jenkins Controller Initial Setup

1. SSH into the controller:
   ```bash
   ssh -i jenkins-key.pem ubuntu@<CONTROLLER_PUBLIC_IP>
   ```

2. Get the initial admin password:
   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```

3. Open `http://<CONTROLLER_PUBLIC_IP>:8080` in your browser

4. Paste the initial password and proceed through the setup wizard

5. Install **suggested plugins** and then additionally install:
   - Pipeline
   - Git
   - GitHub Branch Source
   - Docker Pipeline
   - Credentials Binding
   - Pipeline Utility Steps
   - SonarQube Scanner
   - Blue Ocean

6. Create an admin user (replace the default initial password)

---

## Step 3: Configure the Build Agent

1. Go to **Manage Jenkins → Nodes → New Node**
2. Set:
   - **Node name**: `linux-agent`
   - **Type**: Permanent Agent
   - **Remote root directory**: `/home/ubuntu/jenkins-agent`
   - **Labels**: `linux-agent`
   - **Usage**: Use this node as much as possible
   - **Launch method**: Launch agents via SSH
     - **Host**: `<AGENT_PRIVATE_IP>` (from Terraform output)
     - **Credentials**: Add SSH key (ubuntu user + private key)
     - **Host Key Verification Strategy**: Non-verifying
3. Click **Save** and verify the agent comes online

---

## Step 4: Configure Jenkins Credentials

Go to **Manage Jenkins → Credentials → System → Global credentials** and add:

| Credential Type | ID | Description |
|----------------|-----|-------------|
| AWS Credentials | `aws-credentials` | AWS Access Key + Secret Key |
| Secret text | `github-pat` | GitHub Personal Access Token |
| Secret text | `sonarqube-token` | SonarQube project token (added in Task 4) |
| Username/Password | `ecr-credentials` | Docker / ECR credentials |
| Secret text | `slack-webhook-url` | Slack incoming webhook URL |
| SSH Username with private key | `jenkins-agent-ssh` | SSH key for agent connection |

---

## Step 5: Configure GitHub Integration

1. Go to **Manage Jenkins → System**
2. Under **GitHub Servers**, click **Add GitHub Server**
3. Set:
   - **Name**: `GitHub`
   - **API URL**: `https://api.github.com`
   - **Credentials**: Select `github-pat`
4. Click **Test connection** to verify
5. Check **Manage hooks** to allow Jenkins to create webhooks

---

## Step 6: Verify Setup

1. **Dashboard**: Jenkins should show the dashboard with no jobs
2. **Nodes**: `linux-agent` should appear online under Manage Jenkins → Nodes
3. **Credentials**: All 6 credentials listed under Manage Jenkins → Credentials
4. **Plugins**: All required plugins listed under Manage Jenkins → Plugins → Installed

### Sanity Check Pipeline

Create a new Pipeline job with the `pipelines/Jenkinsfile.sanity` and run it. It should execute `echo hello` on the `linux-agent` and succeed.

---

## Installed Software (via user_data)

| Software | Version | Purpose |
|----------|---------|---------|
| Java 17 | OpenJDK 17 | Jenkins runtime |
| Jenkins | LTS | CI/CD server |
| Git | Latest | Source code management |
| Docker | Latest | Container builds |
| AWS CLI | v2 | AWS resource management |
| Terraform | Latest | Infrastructure as Code |
| Node.js 18 | LTS | Application runtime |
| Trivy | Latest | Container vulnerability scanning |
| tfsec | Latest | Terraform security scanning |
