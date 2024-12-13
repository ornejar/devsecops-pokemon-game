variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# Networking
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

# Cluster
variable "cluster_name" {
  type    = string
  default = "pokemon-eks-cluster"
}

# Database
variable "db_username" {
  type      = string
  default   = "postgres_user"
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_name" {
  type    = string
  default = "trainerdb"
}
