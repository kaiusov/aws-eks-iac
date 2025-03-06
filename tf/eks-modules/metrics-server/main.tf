locals {
  helm_repo_metrics_server = "https://kubernetes-sigs.github.io/metrics-server/"
}

# resource "kubernetes_namespace" "metrics_server" {
#   metadata {
#     name = var.metrics_server_namespace
#   }
# }

data "template_file" "metrics_server" {
  template = file("${path.module}/templates/metrics-server-values.yaml")
}

resource "helm_release" "metrics_server" {
  name        = "metrics-server"
  chart       = "metrics-server"
  repository  = local.helm_repo_metrics_server
  version     = var.metrics_server_chart_version
  # namespace   = var.metrics_server_namespace
  namespace = "default"
  max_history = var.max_history

  values = [
    data.template_file.metrics_server.rendered
  ]

  # depends_on = [
  #   kubernetes_namespace.metrics_server
  # ]
}