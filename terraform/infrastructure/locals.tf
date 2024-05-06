locals {
  service_name = join("-", [var.product, var.service])
  tags = {
    Environment = "development"
    Name        = local.service_name
    Terraform   = true
  }
  tags_subnets = {
    Environment              = "development"
    Name                     = local.service_name
    Terraform                = true
    "kubernetes.io/role/elb" = 1
  }
  openid_connect_provider_url_without_https = replace(module.containers.openid_connect_provider_url, "https://", "")
}