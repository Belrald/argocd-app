variable "name" {
  default = ""
  type = string
}

variable "subnet_ids" {
  type = list
  default = []
}

variable "capacity_type" {
  default = "ON_DEMAND"
  type = string
}

variable "instance_types" {
  default = ["t3.small"]
  type = list
}

variable "desired_size" {
  type = number
  default = 1
}
variable "max_size" {
  type = number
  default = 5
}
variable "min_size" {
  type = number
  default = 0
}

variable "max_unavailable" {
  default = 1
  type = number
}

