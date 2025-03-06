locals {
  helm_repo_nginx_server = "https://charts.bitnami.com/bitnami/"
}

# resource "kubernetes_namespace" "nginx_server" {
#   metadata {
#     name = var.nginx_server_namespace
#   }
# }

data "template_file" "nginx_server" {
  template = file("${path.module}/templates/nginx-server-values.yaml")
}

resource "helm_release" "nginx_server" {
  name        = "nginx-server"
  chart       = "nginx"
  repository  = local.helm_repo_nginx_server
  version     = var.nginx_server_chart_version
  # namespace   = var.nginx_server_namespace
  max_history = var.max_history

  values = [
    data.template_file.nginx_server.rendered
  ]

  # depends_on = [
  #   kubernetes_namespace.nginx_server
  # ]
}