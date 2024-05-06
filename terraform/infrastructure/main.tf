module "docker_repository" {
  source               = "../modules/containers/ecr"
  name                 = local.service_name
  image_tag_mutability = var.image_tag_mutability
  scan_on_push         = var.scan_on_push
}

module "networking" {
  source             = "../modules/networking/vpc"
  vpc_cidr           = var.vpc_cidr
  tags               = local.tags
  tags_subnets       = local.tags_subnets
  availability_zones = data.aws_availability_zones.available.names
  subnets_cidr       = var.subnets_cidr
  subnet_type        = var.subnet_type
}

module "containers" {
  source          = "../modules/containers/eks"
  name            = local.service_name
  subnet_ids      = module.networking.subnet_ids
  instance_types  = var.instance_types
  desired_size    = var.desired_size
  max_size        = var.max_size
  min_size        = var.min_size
  max_unavailable = var.max_unavailable
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "5.19.12"

  set {
    name  = "server.service.type"
    value = "NodePort"
  }
}

resource "kubernetes_manifest" "argo-github" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "argo-github"
      namespace = "argocd"
    }
    spec = {
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "argocd"
      }
      project = "default"
      source = {
        repoURL        = "https://github.com/Belrald/argocd-app.git"
        targetRevision = "HEAD"
        path           = "deployment"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true",
          "Validate=true",
          "PrunePropagationPolicy=foreground"
        ]
      }
    }
  }
}

resource "aws_iam_openid_connect_provider" "main" {
  url = module.containers.openid_connect_provider_url

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [data.external.thumbprint.result.thumbprint]
}

resource "kubernetes_manifest" "service-account" {
  manifest = {
    apiVersion = "v1"
    kind       = "ServiceAccount"
    metadata = {
      name      = "aws-load-balancer-controller"
      namespace = "kube-system"
      labels = {
        "app.kubernetes.io/name"       = "aws-load-balancer-controller"
        "app.kubernetes.io/part-of"    = "argocd"
        "app.kubernetes.io/component"  = "controller"
        "app.kubernetes.io/managed-by" = "terraform"
        "app.kubernetes.io/instance"   = "argocd"
      }
      annotations = {
        "eks.amazonaws.com/role-arn" : "${aws_iam_role.oidc.arn}"
      }
    }
  }
}

resource "helm_release" "eks-chart" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.5.3"

  set {
    name  = "clusterName"
    value = local.service_name
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
}


