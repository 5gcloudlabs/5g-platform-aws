resource "kubernetes_config_map" "pdu_dashboard" {
  depends_on       = [kubernetes_namespace_v1.monitoring]
  metadata {
    name      = "pdu-dashboard"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "pdu-dashboard.json" = jsonencode({
      uid           = "pdu",
      title         = "PDU Session Establishment Dashboard",
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
          title     = "Successful PDU Session Establishment Count",
          datasource = {
            type = "loki",
            name = "Loki"
          },
          targets = [
            {
              refId        = "A",
              expr         = "count_over_time({container=\"smf\"} |= \"| POST    | /nsmf-pdusession/v1/sm-contexts |\" [1h])",
              legendFormat = ""
            }
          ]
        }
      ]
    })
  }
}
