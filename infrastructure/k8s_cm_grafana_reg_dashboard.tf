resource "kubernetes_config_map" "reg_dashboard" {
  depends_on       = [kubernetes_namespace_v1.monitoring]
  metadata {
    name      = "reg-dashboard"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "reg-dashboard.json" = jsonencode({
      uid           = "reg",
      title         = "UE Registration Dashboard",
      schemaVersion = 40,
      editable      = true,
      annotations = {
        list = [
          {
            builtIn   = 1,
            datasource = {
              type = "grafana",
              uid  = "-- Grafana --"
            },
            enable    = true,
            hide      = true,
            iconColor = "rgba(0, 211, 255, 1)",
            name      = "Annotations & Alerts",
            type      = "dashboard"
          }
        ]
      },
      panels = [
        {
          type      = "stat",
          title     = "Successful UE Registration Accept Count",
          datasource = {
            type = "loki",
            name = "Loki"
          },
          targets = [
            {
              refId        = "A",
              expr         = "count_over_time({container=\"amf\"} |= \"Registration Accept\" [1h])",
              legendFormat = ""
            }
          ]
        }
      ]
    })
  }
}
