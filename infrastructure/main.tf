#######################
# Fetch Availability Zones
#######################
data "aws_availability_zones" "available" {}

#######################
# VPC Setup
#######################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.16.0"

  name                 = "pokemon-vpc"
  cidr                 = var.vpc_cidr
  azs                  = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  public_subnet_tags   = { "kubernetes.io/role/elb" = "1" }
  private_subnet_tags  = { "kubernetes.io/role/internal-elb" = "1" }
}

#######################
# EKS Cluster
#######################
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 20.0"
  cluster_name    = var.cluster_name
  cluster_version = "1.31"
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  eks_managed_node_groups = {
    default = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 2
      instance_types   = ["t3.small"]
    }
  }
}

#######################
# RDS PostgreSQL
#######################
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "pokemon-db-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "RDS security group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow Postgres from EKS nodes"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "postgres" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "14"
  instance_class       = "db.t4g.micro"
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot  = true
}

#######################
# Cognito User Pool
#######################
resource "aws_cognito_user_pool" "user_pool" {
  name = "pokemon-user-pool"

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
  }
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name                       = "pokemon-user-pool-client"
  user_pool_id               = aws_cognito_user_pool.user_pool.id
  allowed_oauth_flows        = ["implicit"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes       = ["email", "openid"]
  callback_urls              = ["http://localhost:3000"]
}

#######################
# SQS Queues
#######################
resource "aws_sqs_queue" "fetch_pokemon_queue" {
  name = "fetch_pokemon_queue"
}

resource "aws_sqs_queue" "updated_pokemon_queue" {
  name = "updated_pokemon_queue"
}
