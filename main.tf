# Main Terraform configuration for dual password management
# This module generates and manages two passwords: active and backup

terraform {
  required_version = ">= 1.0"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Local variables for password management logic
locals {
  # Determine if we should swap passwords
  should_swap = var.swap_passwords

  # Detect if backup password is being rotated
  # This is detected by comparing the current state (if exists) with the new version
  # For initial creation, we allow it
  backup_rotation_detected = var.backup_password_version != var.active_password_version

  # Determine the actual active and backup password values
  # If swapping, the backup becomes active and vice versa
  # If not swapping, use the original assignments
  active_password_value = local.should_swap ? random_password.backup.result : random_password.active.result
  backup_password_value = local.should_swap ? random_password.active.result : random_password.backup.result

  # Labels to track which password is which after swapping
  active_password_label = local.should_swap ? "backup (now active)" : "active"
  backup_password_label = local.should_swap ? "active (now backup)" : "backup"
}



# Generate the "active" password
# This password is generated once and kept unless explicitly rotated via swap
resource "random_password" "active" {
  length  = var.password_length
  special = var.include_special_chars
  upper   = var.include_uppercase
  lower   = var.include_lowercase
  numeric = var.include_numbers

  # Keepers ensure the password is only regenerated when these values change
  keepers = {
    # This ensures the password stays stable unless we trigger regeneration
    version = var.active_password_version
  }
}

# Generate the "backup" password
# This can be rotated independently by changing the backup_password_version
resource "random_password" "backup" {
  length  = var.password_length
  special = var.include_special_chars
  upper   = var.include_uppercase
  lower   = var.include_lowercase
  numeric = var.include_numbers

  # Keepers for backup password rotation
  keepers = {
    # Change this value to rotate the backup password
    version = var.backup_password_version
  }
}

# Store the effective active password (considering swaps)
# This uses a null_resource to track the swap state
resource "terraform_data" "active_password_state" {
  input = {
    password = local.active_password_value
    label    = local.active_password_label
    swapped  = local.should_swap
  }
}

# Store the effective backup password (considering swaps)
resource "terraform_data" "backup_password_state" {
  input = {
    password = local.backup_password_value
    label    = local.backup_password_label
    swapped  = local.should_swap
  }
}
