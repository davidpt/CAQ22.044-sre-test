output "Manifest" {
  value = jsondecode(file("${var.Manifest_path}"))
}
