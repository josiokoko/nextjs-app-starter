# resource "aws_ecr_repository" "repository" {
#   name                 = var.registry_name
#   //image_tag_mutability = "MUTABLE"

#   tags                 = {
#     Name = var.registry_name
#   }

#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }

data "aws_ecr_repository" "repository" {
   name = "fargate-cicd-pipeline"
}


output "registry_id" {
  description = "The account ID of the registry holding the repository."
  value = data.aws_ecr_repository.repository.registry_id
}

output "repository_name" {
  description = "The name of the repository."
  value = data.aws_ecr_repository.repository.name
}

output "repository_url" {
  description = "The URL of the repository."
  value = data.aws_ecr_repository.repository.repository_url
}
