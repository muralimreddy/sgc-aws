resource "aws_ssm_document" "ssm_document" {
  name            = "SG-AWS-RunKubeCtlShellScript"
  document_type   = "Command"
  content         = file("${path.module}/ssm_kubectl_document.json")
}
