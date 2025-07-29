resource "kubernetes_config_map" "domain-name-cm" {
  depends_on       = [module.eks]
  metadata {
    name      = "domain-name-cm"
    namespace = "default"
  }

  data = {
    DOMAIN_NAME = "${var.domain_name}"
  }
}
