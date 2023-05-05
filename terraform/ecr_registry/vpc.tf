resource "aws_vpc" "s3_jenkins_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = var.tenancy

  tags = {
    Name = "${terraform.workspace}-s3-jenkins-vpc"
  }
}