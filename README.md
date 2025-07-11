# RentZone Infrastructure ECS

This repository contains Terraform configurations for deploying the RentZone application infrastructure on AWS using Amazon Elastic Container Service (ECS).

## Project Overview

RentZone is a web application that allows users to rent properties. This infrastructure project automates the deployment of a scalable, highly available containerized application on AWS ECS with supporting services including load balancing, database, and monitoring.

## Architecture

The infrastructure deploys the following AWS resources:

- **ECS Cluster** - Container orchestration platform
- **ECS Service** - Manages running tasks and desired state
- **ECS Task Definition** - Defines container specifications
- **Application Load Balancer** - Routes traffic to ECS tasks
- **RDS Database** - Managed database for application data
- **VPC** - Virtual private cloud with public and private subnets
- **Security Groups** - Network access control
- **IAM Roles** - Service permissions and access control
- **Route 53** - DNS management (optional)
- **ECR Repository** - Container image storage

## Prerequisites

Before deploying this infrastructure, ensure you have:

- **AWS CLI** installed and configured with appropriate credentials
- **Terraform** installed (version 1.0 or later)
- **Docker** installed (for building application images)
- **AWS account** with permissions to create ECS, EC2, RDS, and IAM resources
- **Domain name** (optional, for custom DNS)

## Environment Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/ALEX77063/rentzone-infrastructure-ecs.git
   cd rentzone-infrastructure-ecs
   ```

2. **Configure AWS credentials**
   ```bash
   aws configure
   ```

3. **Initialize Terraform**
   ```bash
   terraform init
   ```

4. **Create terraform.tfvars file**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
   Edit the file with your specific values.

## Configuration Variables

Key variables you need to configure in `terraform.tfvars`:

```hcl
# Project basics
project_name = "rentzone"
environment  = "dev"

# Network configuration
vpc_cidr = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]

# ECS configuration
app_image = "your-account-id.dkr.ecr.us-east-1.amazonaws.com/rentzone:latest"
app_port  = 80
app_count = 2

# Database configuration
db_name     = "rentzone"
db_username = "admin"
db_password = "your-secure-password"

# Domain (optional)
domain_name = "example.com"
```

## Deployment Steps

1. **Plan the deployment**
   ```bash
   terraform plan
   ```

2. **Apply the configuration**
   ```bash
   terraform apply
   ```

3. **Confirm the deployment**
   Type `yes` when prompted to create resources.

4. **Get the application URL**
   ```bash
   terraform output load_balancer_dns_name
   ```

## Application Deployment

Before running Terraform, make sure your application image is available in ECR:

1. **Build and push the application image**
   ```bash
   # Build the Docker image
   docker build -t rentzone .
   
   # Tag for ECR
   docker tag rentzone:latest your-account-id.dkr.ecr.region.amazonaws.com/rentzone:latest
   
   # Push to ECR
   docker push your-account-id.dkr.ecr.region.amazonaws.com/rentzone:latest
   ```

2. **Update the image URL in terraform.tfvars**
   ```hcl
   app_image = "your-account-id.dkr.ecr.region.amazonaws.com/rentzone:latest"
   ```

## File Structure

```
rentzone-infrastructure-ecs/
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── terraform.tfvars.example # Example variables file
├── backend.tf              # Remote state configuration
├── versions.tf             # Terraform and provider versions
├── modules/
│   ├── vpc/               # VPC module
│   ├── ecs/               # ECS module
│   ├── rds/               # RDS module
│   └── alb/               # Load balancer module
└── README.md              # This file
```

## Important Outputs

After deployment, Terraform will output:

- **load_balancer_dns_name** - URL to access your application
- **ecs_cluster_name** - Name of the ECS cluster
- **database_endpoint** - RDS database endpoint
- **ecr_repository_url** - ECR repository URL for application images

## Monitoring and Logs

- **CloudWatch Logs** - ECS task logs are automatically sent to CloudWatch
- **ECS Console** - Monitor service health and task status
- **Load Balancer** - Check target group health

Access logs:
```bash
aws logs describe-log-groups --log-group-name-prefix "/ecs/rentzone"
```

## Scaling

To scale the application:

1. **Update the app_count variable** in terraform.tfvars
2. **Apply the changes**
   ```bash
   terraform apply
   ```

You can also enable auto-scaling by configuring ECS Service Auto Scaling policies.

## Security Considerations

- Database is deployed in private subnets
- Security groups restrict access to necessary ports only
- IAM roles follow least privilege principle
- Application Load Balancer can be configured with SSL/TLS certificates
- Consider using AWS Secrets Manager for sensitive data

## Troubleshooting

### Common Issues

**ECS tasks not starting:**
- Check CloudWatch logs for application errors
- Verify ECR image exists and is accessible
- Check security group rules
- Ensure task definition has sufficient CPU/memory

**Application not accessible:**
- Verify load balancer target group health
- Check security group rules for ALB
- Ensure ECS tasks are running in correct subnets

**Database connection errors:**
- Check database security group rules
- Verify database endpoint and credentials
- Ensure ECS tasks can reach RDS subnets

### Useful Commands

```bash
# Check ECS service status
aws ecs describe-services --cluster rentzone-cluster --services rentzone-service

# View ECS task logs
aws logs tail /ecs/rentzone --follow

# Check load balancer target health
aws elbv2 describe-target-health --target-group-arn arn:aws:elasticloadbalancing:...

# Force new deployment
aws ecs update-service --cluster rentzone-cluster --service rentzone-service --force-new-deployment
```

## Cost Optimization

- Use AWS Fargate Spot for development environments
- Configure ECS Service Auto Scaling to handle traffic variations
- Use RDS instance classes appropriate for your workload
- Enable CloudWatch Container Insights only if needed
- Set up proper tagging for cost tracking

## Cleanup

To destroy all resources:

```bash
terraform destroy
