# Specify the provider (in this case, AWS)
provider "aws" {
  region = "eu-west-2"
}

# Create S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "team-dkr-terraform-state-bucket"
  acl    = "private"
  tags   = {
    "cohort-dkr" = "mar-2024-cloud-engineering-dkr"
    "Name"       = "TerraformStateBucket"
    "Environment" = "Production"
  }
}

# Create ECR Repository
resource "aws_ecr_repository" "team_dkr_repo" {
  name = "team-dkr-repo"
  tags = {
    "cohort-dkr" = "mar-2024-cloud-engineering-dkr"
  }
}

# Create Elastic Beanstalk Application
resource "aws_elastic_beanstalk_application" "team_dkr_app" {
  name = "team-dkr-app"
  tags = {
    "cohort-dkr" = "mar-2024-cloud-engineering-dkr"
  }
}

# Create Elastic Beanstalk Environment
resource "aws_elastic_beanstalk_environment" "team_dkr_eb_env" {
  name                = "team-dkr-eb-env"
  application         = aws_elastic_beanstalk_application.team_dkr_app.name
  solution_stack_name = "64bit Amazon Linux 2 v3.3.3 running Python 3.9" # Example solution stack

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DATABASE_URL"
    value     = aws_db_instance.team_dkr_db_instance.address
  }

  # Link to the S3 bucket for application artifacts
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "S3_BUCKET_NAME"
    value     = aws_s3_bucket.team_dkr_app_bucket.bucket
  }

  tags = {
    "cohort-dkr" = "mar-2024-cloud-engineering-dkr"
  }
}

# Create RDS PostgreSQL Database
resource "aws_db_instance" "team_dkr_db_instance" {
  engine            = "postgres"
  instance_class    = "db.t2.micro"
  allocated_storage = 20
  identifier        = "team-dkr-db-instance"
  tags = {
    "cohort-dkr" = "mar-2024-cloud-engineering-dkr"
  }
}

# Create S3 Bucket for Elastic Beanstalk Application
resource "aws_s3_bucket" "team_dkr_app_bucket" {
  bucket = "team-dkr-app-bucket"
  acl    = "private"

  tags = {
    "cohort-dkr" = "mar-2024-cloud-engineering-dkr"
    "Name"       = "MyElasticBeanstalkAppBucket"
    "Environment" = "Production"
  }
}