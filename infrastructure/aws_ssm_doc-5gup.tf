resource "aws_ssm_document" "ssm_doc_5gup_node_eni_state_up" {
  depends_on = [aws_network_interface_attachment.upf-N6-nic-attachment]
  name            = "ssm_doc_5gup_node_eni_state_up"
  document_format = "YAML"
  document_type   = "Command"

  content = <<DOC
schemaVersion: '1.2'
description: Bring up the additional interfaces of the instance.
parameters: {}
runtimeConfig:
  'aws:runShellScript':
    properties:
      - id: '0.aws:runShellScript'
        runCommand:
          - ip link set ens4 up
          - ip link set ens5 up
          - ip link set ens6 up
          - ip link set ens7 up
          - ip link set ens8 up
DOC
}

resource "aws_ssm_association" "ssm_association_5gup_node" {
  name = aws_ssm_document.ssm_doc_5gup_node_eni_state_up.name

  targets {
    key    = "tag:Name"
    values = ["5g-userplane-node"]
  }
}