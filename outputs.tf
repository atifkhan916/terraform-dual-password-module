# Output values for the password management module

output "active_password" {
  description = "The current active password (sensitive)"
  value       = local.active_password_value
  sensitive   = true
}

output "backup_password" {
  description = "The current backup password (sensitive)"
  value       = local.backup_password_value
  sensitive   = true
}

output "active_password_label" {
  description = "Label indicating the source of the active password"
  value       = local.active_password_label
}

output "backup_password_label" {
  description = "Label indicating the source of the backup password"
  value       = local.backup_password_label
}

output "passwords_swapped" {
  description = "Indicates whether passwords are currently in swapped state"
  value       = local.should_swap
}

output "active_password_version" {
  description = "Current version of the active password"
  value       = var.active_password_version
}

output "backup_password_version" {
  description = "Current version of the backup password"
  value       = var.backup_password_version
}

# Non-sensitive output for verification (shows only metadata)
output "password_status" {
  description = "Status information about the password configuration"
  value = {
    active_label          = local.active_password_label
    backup_label          = local.backup_password_label
    swapped               = local.should_swap
    active_version        = var.active_password_version
    backup_version        = var.backup_password_version
    password_length       = var.password_length
    include_special_chars = var.include_special_chars
  }
}
