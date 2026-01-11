# Input variables for the password management module

variable "password_length" {
  description = "Length of the generated passwords"
  type        = number
  default     = 16

  validation {
    condition     = var.password_length >= 8 && var.password_length <= 128
    error_message = "Password length must be between 8 and 128 characters."
  }
}

variable "include_special_chars" {
  description = "Include special characters in the password"
  type        = bool
  default     = true
}

variable "include_uppercase" {
  description = "Include uppercase letters in the password"
  type        = bool
  default     = true
}

variable "include_lowercase" {
  description = "Include lowercase letters in the password"
  type        = bool
  default     = true
}

variable "include_numbers" {
  description = "Include numbers in the password"
  type        = bool
  default     = true
}

variable "active_password_version" {
  description = "Version identifier for the active password. Change this value to regenerate the active password."
  type        = string
  default     = "v1"
}

variable "backup_password_version" {
  description = "Version identifier for the backup password. Change this value to rotate the backup password."
  type        = string
  default     = "v1"
}

variable "swap_passwords" {
  description = "Set to true to swap the active and backup passwords. The backup becomes active and vice versa."
  type        = bool
  default     = false
}
variable "rotate_backup" {
  description = "Set to true to rotate the backup password"
  type        = bool
  default     = false
}