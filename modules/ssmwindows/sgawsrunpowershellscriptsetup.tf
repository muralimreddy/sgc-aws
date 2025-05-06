resource "aws_ssm_document" "sg_aws_run_powershell_script" {
  name          = "SG-AWS-RunPowerShellScript"
  document_type = "Command"
  version_name  = "1.0"

  content = jsonencode({
    schemaVersion = "2.2"
    description   = "Service Graph AWS - aws:runPowerShellScript"
    mainSteps = [
      {
        action = "aws:runPowerShellScript"
        name   = "runPowerShellScript"
        inputs = {
          timeoutSeconds = 3600
          runCommand     = jsondecode(file("${path.module}/powershell-commands.json"))
        }
      }
    ]
  })
}
