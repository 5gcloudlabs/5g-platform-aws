#Allow API server to connect to the webhook deployment (Istiod) on port 15017
resource "aws_security_group_rule" "allow_sidecar_injection_SG_rule" {
  depends_on = [module.eks]
  description = "Webhook container port, From Control Plane"
  protocol    = "tcp"
  type        = "ingress"
  from_port   = 15017
  to_port     = 15017

  security_group_id        = module.eks.node_security_group_id
  source_security_group_id = module.eks.cluster_primary_security_group_id
}

#Allow ingress on port 80 between nodes
resource "aws_security_group_rule" "allow_http_traffic_between_nodes_SG_rule" {
  depends_on = [module.eks]
  description = "allow http traffic between nodes"
  protocol    = "tcp"
  type        = "ingress"
  from_port   = 80
  to_port     = 80

  security_group_id        = module.eks.node_security_group_id
  source_security_group_id = module.eks.node_security_group_id
}
