resource "aws_ssm_document" "sg_aws_run_shell_script" {
  name          = "SG-AWS-RunShellScript"
  document_type = "Command"
  version_name  = "1.0"

  content = file("${path.module}/ssm_run_shell_script.json")
}
