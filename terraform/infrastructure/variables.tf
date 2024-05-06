variable "region" {
  type    = string
  default = "us-west-2"
}

# variable will be provided through a secured mean (e.g terraform cloud)
variable "access_key" {
  type    = string
  default = ""

}

# variable will be provided through a secured mean (e.g terraform cloud)
variable "secret_key" {
  type    = string
  default = ""
}

variable "product" {
  type        = string
  description = "company name"
  default     = "xdeel"
}

variable "service" {
  type        = string
  description = "Name of the ECR repository"
  default     = "print-ip"
}

variable "image_tag_mutability" {
  type    = string
  default = "MUTABLE"
}

variable "scan_on_push" {
  type    = bool
  default = true
}

variable "vpc_cidr" {
  default = "10.100.0.0/16"
}

variable "subnets_cidr" {
  description = "list of private subnets id"
  type        = list(string)
  default = [
    "10.100.20.0/24",
    "10.100.21.0/24",
    "10.100.22.0/24",
  ]
}
variable "subnet_type" {
  default = "public"
}

variable "instance_types" {
  default = ["t3.medium"]
  type    = list(any)
}

variable "desired_size" {
  type    = number
  default = 1
}
variable "max_size" {
  type    = number
  default = 5
}
variable "min_size" {
  type    = number
  default = 0
}

variable "max_unavailable" {
  default = 1
  type    = number
}