# RentZone Infrastructure ECS

This repository contains Terraform infrastructure code for deploying the RentZone application on AWS using Amazon ECS (Elastic Container Service). The infrastructure is built using modular Terraform configuration with reusable modules.

## Architecture Overview

The infrastructure deploys a complete, production-ready web application stack with the following components:

- **VPC** with public and private subnets across 2 availability zones
- **NAT Gateway** for private subnet internet access
- **Security Groups** for network access control
- **RDS Database** in private data subnets
- **Application Load Balancer** with SSL certificate
- **ECS Cluster** with Fargate tasks
- **S3 Bucket** for environment files
- **Route 53** DNS records
- **Auto Scaling** for ECS services

## Prerequisites

Before deploying this infrastructure, you need:

- **AWS CLI** configured with appropriate credentials
- **Terraform** installed (version compatible with AWS provider 5.74.0)
- **AWS Profile** named `terraform-user` configured
- **Domain name** registered and managed in Route 53
- **S3 bucket** for Terraform state: `alex77063-terraform-remote-state`
- **DynamoDB table** for state locking: `terraform-state-lock`

## File Structure

```
rentzone-infrastructure-ecs/
├── main.tf                 # Main infrastructure configuration
├── variables.tf            # Input variables
├── provider.tf             # AWS provider configuration
├── backend.tf              # Terraform backend configuration
├── versions.tf             # Provider version constraints
├── .gitignore             # Git ignore rules
└── README.md              # This file
```

## Required Variables

Create a `terraform.tfvars` file with the following variables:

```hcl
# Environment configuration
region       = "us-east-1"
project_name = "rentzone"
environment  = "dev"

# VPC configuration
vpc_cidr                     = "10.0.0.0/16"
public_subnet_az1_cidr       = "10.0.1.0/24"
public_subnet_az2_cidr       = "10.0.2.0/24"
private_app_subnet_az1_cidr  = "10.0.3.0/24"
private_app_subnet_az2_cidr  = "10.0.4.0/24"
private_data_subnet_az1_cidr = "10.0.5.0/24"
private_data_subnet_az2_cidr = "10.0.6.0/24"

# Security configuration
ssh_ip = "your.ip.address.here/32"

# Database configuration
database_snapshot_identifier = "your-snapshot-id"
database_instance_class      = "db.t3.micro"
database_instance_identifier = "rentzone-db"
multi_az_deployment          = false

# SSL Certificate configuration
domain_name       = "yourdomain.com"
alternative_names = "*.yourdomain.com"

# Load Balancer configuration
target_type = "ip"

# S3 configuration
env_file_bucket_name = "your-env-file-bucket"
env_file_name        = "rentzone.env"

# ECS configuration
architecture     = "X86_64"
container_image  = "your-account-id.dkr.ecr.us-east-1.amazonaws.com/rentzone:latest"

# Route 53 configuration
record_name = "www"
```

## Deployment Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/ALEX77063/rentzone-infrastructure-ecs.git
   cd rentzone-infrastructure-ecs
   ```

2. **Configure AWS credentials**
   ```bash
   aws configure --profile terraform-user
   ```

3. **Create your variables file**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your specific values
   ```

4. **Initialize Terraform**
   ```bash
   terraform init
   ```

5. **Plan the deployment**
   ```bash
   terraform plan
   ```

6. **Apply the configuration**
   ```bash
   terraform apply
   ```

7. **Access your application**
   The output will show your website URL: `https://www.yourdomain.com`

## Terraform Modules Used

This infrastructure uses custom Terraform modules from the `ALEX77063/terraform-modules` repository:

- **vpc** - Creates VPC with public and private subnets
- **nat-gateway** - Sets up NAT gateways for private subnet internet access
- **security-groups** - Configures security groups for different tiers
- **rds** - Deploys RDS database instance
- **acm** - Requests SSL certificates from AWS Certificate Manager
- **alb** - Creates Application Load Balancer with target groups
- **s3** - Creates S3 bucket for environment files
- **iam-role** - Sets up ECS task execution role
- **ecs** - Deploys ECS cluster, task definition, and service
- **asg-ecs** - Configures auto scaling for ECS service
- **route-53** - Creates DNS records

## Environment File Setup

Before deployment, create a `rentzone.env` file with your application environment variables and upload it to the S3 bucket specified in `env_file_bucket_name`. This file should contain:

```env
DB_HOST=your-rds-endpoint
DB_NAME=your-database-name
DB_USER=your-database-user
DB_PASSWORD=your-database-password
# Add other environment variables as needed
```

## Container Image Preparation

Ensure your container image is available in ECR:

1. **Build and tag your image**
   ```bash
   docker build -t rentzone .
   docker tag rentzone:latest your-account-id.dkr.ecr.us-east-1.amazonaws.com/rentzone:latest
   ```

2. **Push to ECR**
   ```bash
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin your-account-id.dkr.ecr.us-east-1.amazonaws.com
   docker push your-account-id.dkr.ecr.us-east-1.amazonaws.com/rentzone:latest
   ```

## Important Notes

- **Remote State**: Terraform state is stored in S3 bucket `alex77063-terraform-remote-state`
- **State Locking**: DynamoDB table `terraform-state-lock` prevents concurrent modifications
- **Provider Profile**: Uses AWS profile `terraform-user` for authentication
- **Default Tags**: All resources are tagged with Automation, Project, and Environment
- **SSL Certificate**: Automatically validates domain ownership for SSL certificate

## Outputs

After successful deployment, you'll get:
- **website_url** - The complete URL to access your application

## Monitoring and Maintenance

- **ECS Service**: Monitor service health in the ECS console
- **Load Balancer**: Check target group health in the ALB console
- **Auto Scaling**: ECS service will automatically scale based on configured metrics
- **Logs**: Application logs are available in CloudWatch

## Security Features

- **Private Subnets**: Application and database tiers are in private subnets
- **Security Groups**: Restricts traffic to necessary ports and sources
- **SSL/TLS**: Automatic SSL certificate provisioning and renewal
- **IAM Roles**: Least privilege access for ECS tasks
- **Environment Variables**: Sensitive data stored in S3 and accessed securely

## Troubleshooting

**Common issues and solutions:**

1. **State bucket doesn't exist**: Create the S3 bucket `alex77063-terraform-remote-state` first
2. **DynamoDB table missing**: Create the `terraform-state-lock` table with `LockID` as primary key
3. **Profile not found**: Configure AWS CLI with profile `terraform-user`
4. **Domain validation fails**: Ensure domain is managed in Route 53
5. **Container image not found**: Verify ECR repository exists and image is pushed

## Cleanup

To destroy all resources:

```bash
terraform destroy
