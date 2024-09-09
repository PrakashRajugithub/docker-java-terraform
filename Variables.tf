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