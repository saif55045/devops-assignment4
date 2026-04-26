# DevOps Assignment 4 — CI/CD Pipeline with Jenkins, Docker, SonarQube & Blue-Green Deployment

## Overview

This assignment builds a complete CI/CD pipeline using Jenkins and Groovy on top of the AWS infrastructure provisioned in Assignment 3. It covers Jenkins setup, declarative pipelines, shared libraries, SonarQube integration, Docker/ECR workflows, Terraform CI/CD, and Blue-Green deployments.

| Task | Description | Key Technologies |
|------|-------------|-----------------|
| Task 1 | Jenkins Installation & Basic Configuration | Jenkins, Terraform, EC2 |
| Task 2 | Declarative Pipeline with Parallel Stages | Jenkinsfile, Node.js, JUnit |
| Task 3 | Reusable Jenkins Shared Library in Groovy | Groovy, Shared Libraries |
| Task 4 | Code Quality with SonarQube Integration | SonarQube, Code Coverage |
| Task 5 | Docker Build, Vulnerability Scanning & ECR Push | Docker, Trivy, AWS ECR |
| Task 6 | Terraform CI/CD Pipeline | Terraform, tfsec, Jenkins |
| Task 7 | Blue-Green Deployment to AWS | ALB, ASG, Blue-Green |

---

## Prerequisites

| Tool | Version |
|------|---------|
| Terraform | >= 1.5 |
| AWS CLI | >= 2.0 (configured with `aws configure`) |
| Jenkins | LTS (installed via user_data) |
| Docker | >= 24.0 |
| Node.js | >= 18.x (for sample app) |
| An AWS account with IAM permissions | — |

---

## Project Structure

```
assignment-4/
├── README.md                          # This file
├── app/                               # Sample Node.js Express application
│   ├── package.json
│   ├── src/
│   │   └── app.js
│   ├── tests/
│   │   ├── unit/
│   │   │   └── app.test.js
│   │   └── integration/
│   │       └── app.integration.test.js
│   ├── Dockerfile                     # Multi-stage Dockerfile (Task 5)
│   └── .trivyignore                   # Trivy CVE ignore file (Task 5)
├── jenkins/                           # Jenkins setup documentation
│   ├── plugins.txt                    # Installed plugins list
│   ├── setup.md                       # Controller & agent setup guide
│   └── terraform/                     # Terraform for Jenkins infra
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── terraform.tfvars
├── pipelines/                         # All Jenkinsfiles
│   ├── Jenkinsfile                    # Main CI/CD pipeline (Task 2)
│   ├── Jenkinsfile.infra              # Terraform CI/CD pipeline (Task 6)
│   ├── Jenkinsfile.rollback           # Manual rollback pipeline (Task 7)
│   └── Jenkinsfile.sanity             # Sanity check pipeline (Task 1)
├── shared-library/                    # Jenkins Shared Library (Task 3)
│   ├── README.md
│   ├── vars/
│   │   ├── notifySlack.groovy
│   │   ├── buildAndPushImage.groovy
│   │   └── runSonarScan.groovy
│   └── src/
│       └── org/
│           └── devops/
│               ├── NotificationService.groovy
│               └── DockerHelper.groovy
├── terraform/                         # Infrastructure Terraform (Tasks 5, 7)
│   ├── ecr.tf                         # ECR repository + lifecycle (Task 5)
│   ├── blue-green.tf                  # Blue-Green ASGs + Target Groups (Task 7)
│   ├── sonarqube.tf                   # SonarQube EC2 (Task 4)
│   ├── variables.tf
│   ├── outputs.tf
│   └── provider.tf
└── observability/                     # (Placeholder for Prometheus/Grafana if needed)
    └── notes.md
```

---

## How to Set Up

### 1. Jenkins Controller & Agent (Task 1)

```bash
cd jenkins/terraform
terraform init
terraform plan
terraform apply
```

After apply, access Jenkins at `http://<CONTROLLER_PUBLIC_IP>:8080`. Complete the setup wizard, install required plugins, and configure the agent node.

### 2. Run the Sample Application Locally

```bash
cd app
npm install
npm start          # Runs on http://localhost:3000
npm run test:unit  # Run unit tests
npm run test:int   # Run integration tests
```

### 3. Configure Jenkins Pipelines

1. Create a **Multibranch Pipeline** job pointing to your GitHub repo
2. Create a **Pipeline** job for `infra-pipeline` using `pipelines/Jenkinsfile.infra`
3. Create a **Pipeline** job for `rollback-pipeline` using `pipelines/Jenkinsfile.rollback`

### 4. Tear Down

```bash
# Destroy Blue-Green infra
cd terraform && terraform destroy

# Destroy Jenkins infra
cd jenkins/terraform && terraform destroy
```

---

## Team Contributions

| Member | Tasks | Contribution |
|--------|-------|-------------|
| Member 1 | Tasks 1, 2, 3 | Jenkins setup, pipeline authoring, shared library |
| Member 2 | Tasks 4, 5, 6, 7 | SonarQube, Docker/ECR, Terraform pipeline, Blue-Green |

---

## Important Notes

- Never commit `.terraform/`, `*.tfstate`, `*.pem`, `.env`, or AWS credentials
- All secrets are stored as Jenkins Credentials and referenced by ID
- The shared library lives in a separate repository: `jenkins-shared-library`
- Tag the final submission commit as `assignment-4-final` on the `main` branch
