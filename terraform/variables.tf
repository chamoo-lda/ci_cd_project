#===================== 
#All AWS variables
#=====================
variable "aws_region" {
  description = "AWS region to deploy resources (closest to you = fastest)"
  type        = string
  default     = "eu-west-1"
}

#===================== 
#AWS profile
#=====================
variable "aws_profile" {
  description = ""
  type        = string
  default     = ""
}

#===================== 
#AWS variables for EC2
#=====================
variable "instance_type" {
  description = ""
  type        = string
  default     = "t3.micro"
}

#===================== 
# SSH Key naem for AWS
#=====================
variable "key_name" {
  description = ""
  type        = string
  default     = "ci-cd-project-key"
}

#======================== 
# Allowed SSH IPs for AWS
#========================
variable "allowed_ssh_ip" {
  description = ""
  type        = string
  default     = "0.0.0.0/0" # need to add /32 IPs or SUBNETS
}
