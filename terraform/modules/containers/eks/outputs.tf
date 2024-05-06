output "eks_cluster_name" {
    value = var.name
}

output "openid_connect_provider_url" {
    value = aws_eks_cluster.main.identity.0.oidc.0.issuer
}