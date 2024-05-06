variable "name" {
  type = string
  description = "Name of the ECR repository"
  default = ""
}

variable "image_tag_mutability" {
  type = string
  default = "MUTABLE"
}

variable "scan_on_push" {
  type = bool
  default = false
}