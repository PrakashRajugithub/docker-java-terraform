variable "pub_cidr" {
  default = ["10.2.0.0/24", "10.2.1.0/24", "10.2.2.0/24"]
  type    = list(any)
}

variable "pvt_cidr" {
  default = ["10.2.3.0/24", "10.2.4.0/24", "10.2.5.0/24"]
  type    = list(any)
}

variable "aws_region" {
    description = "AWS Region"
    type = string
    default = "ap-southeast-1"
  
}

data "aws_caller_identity" "current" {}
output "aws_account_number" {
  value = data.aws_caller_identity.current.account_id
}

output "vpcid" {
  value = aws_vpc.new-vpc.id
}


variable "github_owner" {
  description = "The GitHub username or organization that owns the repository"
  type        = string
  default = "PrakashRajugithub"
}

variable "github_repo" {
  description = "The name of the GitHub repository"
  type        = string
  default = "https://github.com/PrakashRajugithub/docker-java-terraform.git"
}

variable "github_branch" {
  description = "The branch of the repository to use"
  type        = string
  default     = "main"  # Optional, set default value
}

variable "github_oauth_token" {
  description = "OAuth token for GitHub API access"
  type        = string
  sensitive   = true  # Marked as sensitive so that it doesn't get logged
 }



output "ecs_task_ip" {
  value = aws_ecs_service.demo_service.network_configuration[0].assign_public_ip
}

