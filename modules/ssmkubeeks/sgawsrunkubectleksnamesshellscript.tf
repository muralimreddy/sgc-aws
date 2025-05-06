resource "aws_ssm_document" "eks_kubectl_script" {
  name          = "SG-AWS-RunKubeCtlEKSNamesShellScript"
  document_type = "Command"
  version_name  = "1.0"

  content = file("${path.module}/ssm_eks_kubectl_names_script.json")
}
