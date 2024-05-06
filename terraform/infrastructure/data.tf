data "aws_availability_zones" "available" {}
data "aws_eks_cluster" "main" {
  name = module.containers.eks_cluster_name
}

data "aws_eks_cluster_auth" "main" {
  name = module.containers.eks_cluster_name
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {

}

data "external" "thumbprint" {
  program = ["${path.module}/thumbprint.sh", data.aws_region.current.name]
}
