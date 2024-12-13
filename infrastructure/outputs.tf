output "vpc_id" {
  value = module.vpc.vpc_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.address
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.user_pool.id
}

output "fetch_pokemon_queue_url" {
  value = aws_sqs_queue.fetch_pokemon_queue.url
}

output "updated_pokemon_queue_url" {
  value = aws_sqs_queue.updated_pokemon_queue.url
}
