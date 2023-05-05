
variable "region" {
  description = "Default region for my s3 bucket"
  type        = string
  default     = "us-east-1"
}


variable "vpc_cidr" {
  description = "Default cidr for vpc"
  type        = string
  default     = "10.20.0.0/16"
}


variable "tenancy" {
  default = "default"
}

variable "registry_name" {
  type = string
}

