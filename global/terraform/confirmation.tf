# See: https://github.com/hashicorp/terraform/issues/25609

variable "confirm" {
  default = null
}

output "validate_confirm" {
  value = null

  precondition {
    condition     = var.confirm == terraform.workspace
    error_message = "For confirmation, you must set '${terraform.workspace}' for variable 'confirm' (e.g., 'terraform plan -var confirm=${terraform.workspace}')."
  }
}
