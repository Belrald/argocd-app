variable "vpc_cidr" {
  type = string
}

variable "enable_dns_support" {
  type = bool
  default = true
}

variable "enable_dns_hostnames" {
  type = bool
  default = true
}

variable "tags" {
  type = map(string)
}

variable "tags_subnets" {
  type = map(string)
}

variable "subnet_type" {
  type = string
  default = "true"
}

variable "subnets_cidr" {
  description = "list of private subnets id"
  type        = list(string)
  default = []
}

variable "availability_zones" {
  description = "list of avaialability zones"
  type        = list(string)
  default = []
}
