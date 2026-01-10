# Terraform Dual Password Management Module

A professional, production-ready Terraform module for managing two random passwords (active and backup) with support for selective rotation and swapping capabilities.

---

## Overview

This module provides a robust solution for managing dual passwords in your infrastructure with the following capabilities:

- ✅ **Dual Password Generation**: Automatically generates two independent passwords (active and backup)
- ✅ **Selective Rotation**: Rotate only the backup password without affecting the active one
- ✅ **Password Swapping**: Seamlessly swap active and backup passwords with zero regeneration
- ✅ **Idempotent Operations**: Passwords remain stable unless explicitly triggered to change
- ✅ **Substrate Agnostic**: Works with any infrastructure - uses only Terraform's random provider
- ✅ **Maximum 2 Applies**: Any operation completes within two `terraform apply` runs
- ✅ **Operation Safety**: Clear separation of concerns between rotation and swapping

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Getting Started](#getting-started)
3. [Step-by-Step Deployment Guide](#step-by-step-deployment-guide)
4. [Configuration](#configuration)
5. [Common Operations](#common-operations)
6. [Verification & Testing](#verification--testing)
7. [Important Constraints](#important-constraints)
8. [Troubleshooting](#troubleshooting)
9. [Advanced Usage](#advanced-usage)
10. [API Reference](#api-reference)

---

## Prerequisites

Before you begin, ensure you have the following installed:

- **Terraform**: Version 1.0 or higher
  ```bash
  terraform version
  ```
  
- **Git**: For cloning the repository
  ```bash
  git --version
  ```

- **PowerShell** (Windows) or **Bash** (Linux/Mac): For running scripts

---

## Getting Started

### Step 1: Clone the Repository

```bash
# Clone the repository
git clone <repository-url>

# Navigate to the module directory
cd terraform-password-generate
```

### Step 2: Review the Module Structure

```
terraform-password-generate/
├── main.tf                    # Core module logic
├── variables.tf               # Input variables
├── outputs.tf                 # Output definitions
├── README.md                  # This file
└── SETUP-GUIDE.md             # Step-by-step setup guide
```

---

## Step-by-Step Deployment Guide

Follow these steps in order for your first deployment:

### Step 1: Initialize Terraform

Initialize the Terraform working directory and download required providers:

```bash
terraform init
```

**Expected Output:**
```
Initializing the backend...
Initializing provider plugins...
- Installing hashicorp/random v3.x.x...

Terraform has been successfully initialized!
```

### Step 2: Create Configuration File

Create a `terraform.tfvars` file with your desired configuration:

```bash
# Create the configuration file
touch terraform.tfvars
```

Add the following content to `terraform.tfvars`:

```hcl
# Password Configuration
password_length       = 16
include_special_chars = true
include_uppercase     = true
include_lowercase     = true
include_numbers       = true

# Version Control (change these to trigger regeneration)
active_password_version = "v1"
backup_password_version = "v1"

# Swap Control
swap_passwords = false
```

### Step 3: Review the Execution Plan

Preview what Terraform will create:

```bash
terraform plan
```

**What to look for:**
- `Plan: 4 to add, 0 to change, 0 to destroy`
- Two `random_password` resources
- Two `terraform_data` resources
- Password outputs marked as `<sensitive>`

### Step 4: Deploy the Module

Apply the configuration to create your passwords:

```bash
terraform apply
```

When prompted, type `yes` to confirm.

**Expected Output:**
```
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

active_password = <sensitive>
active_password_label = "active"
active_password_version = "v1"
backup_password = <sensitive>
backup_password_label = "backup"
backup_password_version = "v1"
passwords_swapped = false
```

### Step 5: Retrieve Your Passwords

View the generated passwords:

```bash
# View active password
terraform output -raw active_password

# View backup password
terraform output -raw backup_password

# View all non-sensitive metadata
terraform output password_status
```

**Example Output:**
```json
{
  "active_label" = "active"
  "active_version" = "v1"
  "backup_label" = "backup"
  "backup_version" = "v1"
  "include_special_chars" = true
  "password_length" = 16
  "swapped" = false
}
```

### Step 6: Verify Idempotency

Run apply again to confirm passwords don't change:

```bash
terraform apply
```

**Expected Output:**
```
No changes. Your infrastructure matches the configuration.
```

✅ **Deployment Complete!** Your dual password management system is now active.

---

## Configuration

### Input Variables

Configure the module by editing `terraform.tfvars`:

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `password_length` | number | 16 | Length of generated passwords (8-128 characters) |
| `include_special_chars` | bool | true | Include special characters (!@#$%^&*) |
| `include_uppercase` | bool | true | Include uppercase letters (A-Z) |
| `include_lowercase` | bool | true | Include lowercase letters (a-z) |
| `include_numbers` | bool | true | Include numbers (0-9) |
| `active_password_version` | string | "v1" | Version identifier for active password |
| `backup_password_version` | string | "v1" | Version identifier for backup password |
| `swap_passwords` | bool | false | Enable password swapping |

### Output Values

The module provides the following outputs:

| Output | Type | Sensitive | Description |
|--------|------|-----------|-------------|
| `active_password` | string | Yes | Current active password value |
| `backup_password` | string | Yes | Current backup password value |
| `active_password_label` | string | No | Label indicating password source |
| `backup_password_label` | string | No | Label indicating password source |
| `passwords_swapped` | bool | No | Whether passwords are currently swapped |
| `active_password_version` | string | No | Current active password version |
| `backup_password_version` | string | No | Current backup password version |
| `password_status` | object | No | Complete status metadata |

---

## Common Operations

### Operation 1: Rotate Backup Password

**Use Case**: Monthly password rotation, security compliance

**Steps:**

1. Edit `terraform.tfvars`:
   ```hcl
   backup_password_version = "v2"  # Change from v1
   ```

2. Apply the change:
   ```bash
   terraform apply
   ```

3. Verify the rotation:
   ```bash
   terraform output password_status
   ```

**Expected Result:**
- ✅ `backup_version` shows "v2"
- ✅ `active_version` still shows "v1"
- ✅ Backup password is different from active

**Apply Count**: 1

---

### Operation 2: Swap Active and Backup Passwords

**Use Case**: Promote backup password to active, zero-downtime migration

**Steps:**

1. Edit `terraform.tfvars`:
   ```hcl
   swap_passwords = true  # Change from false
   ```

2. Apply the change:
   ```bash
   terraform apply
   ```

3. Verify the swap:
   ```bash
   terraform output password_status
   ```

**Expected Result:**
- ✅ `passwords_swapped` shows "true"
- ✅ `active_label` shows "backup (now active)"
- ✅ `backup_label` shows "active (now backup)"
- ✅ Password values swapped positions (no regeneration)

**Apply Count**: 1

---

### Operation 3: Rotate THEN Swap (Common Pattern)

**Use Case**: Generate new password and promote it to active

**Step 1 - Rotate Backup:**

Edit `terraform.tfvars`:
```hcl
backup_password_version = "v2"
swap_passwords = false
```

Apply:
```bash
terraform apply
```

**Step 2 - Swap Passwords:**

Edit `terraform.tfvars`:
```hcl
backup_password_version = "v2"
swap_passwords = true  # Enable swap
```

Apply:
```bash
terraform apply
```

**Result**: New backup password (v2) is now the active password.

**Apply Count**: 2 (maximum)

---

## Verification & Testing

### Quick Verification

Use the included verification script:

```powershell
# PowerShell
.\verify-rotation.ps1
```

**This checks:**
- ✅ Active and backup passwords are different
- ✅ Version numbers match configuration
- ✅ Swap status is accurate
- ✅ Password lengths are correct

### Manual Verification

**Check Version Numbers:**
```bash
terraform output password_status
```

Look for:
```json
{
  "active_version" = "v1"    // Should match your tfvars
  "backup_version" = "v2"    // Should match your tfvars
}
```

**Compare Password Values:**
```bash
# Get both passwords
terraform output -raw active_password
terraform output -raw backup_password

# They should be different
```

**Verify Idempotency:**
```bash
# Run apply multiple times
terraform apply
terraform apply
terraform apply

# Each should show "No changes"
```

### Full Test Suite

Run the comprehensive test suite:

```powershell
.\test-module.ps1
```

**Tests performed:**
1. Initial password generation
2. Idempotency (3 consecutive applies)
3. Backup password rotation
4. Password swapping
5. Swap reversal
6. Multiple rotations

---

## Important Constraints

### 🚫 No Simultaneous Rotation + Swap

**IMPORTANT**: We recommend performing rotation and swapping in separate steps to ensure a clear audit trail.

#### ✅ Correct Approach - Option 1: Rotate THEN Swap

```bash
# Step 1: Rotate
terraform apply -var="backup_password_version=v2"

# Step 2: Swap
terraform apply -var="backup_password_version=v2" -var="swap_passwords=true"
```

#### ✅ Correct Approach - Option 2: Swap THEN Rotate

```bash
# Step 1: Swap
terraform apply -var="swap_passwords=true"

# Step 2: Rotate
terraform apply -var="swap_passwords=true" -var="backup_password_version=v2"
```

**Why this constraint exists:**
- Ensures predictable behavior
- Maintains clear audit trail
- Prevents confusion about password state
- Guarantees maximum 2 applies for any workflow

---

## Troubleshooting

### Issue: Passwords Changing Unexpectedly

**Symptoms**: Passwords regenerate on every apply

**Diagnosis:**
```bash
terraform plan
```

**Common Causes:**
- Version variables changed in `terraform.tfvars`
- State file corruption
- Provider version changed

**Solution:**
1. Check your `terraform.tfvars` for unintended changes
2. Verify version numbers haven't changed
3. Review the plan output carefully

---



### Issue: Can't See Password Values

**Symptoms**: Outputs show `<sensitive>`

**Solution:**
Use the `-raw` flag:
```bash
terraform output -raw active_password
terraform output -raw backup_password
```

---

### Issue: "No changes" but Need to Rotate

**Symptoms**: Want to rotate password but Terraform shows no changes

**Solution:**
Change the version variable in `terraform.tfvars`:
```hcl
backup_password_version = "v2"  # Or any new value
```

---

## Advanced Usage

### Integration with Azure Key Vault

```hcl
module "passwords" {
  source = "./terraform-password-generate"
  
  password_length         = 24
  backup_password_version = var.rotation_trigger
}

resource "azurerm_key_vault_secret" "active" {
  name         = "database-password-active"
  value        = module.passwords.active_password
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "backup" {
  name         = "database-password-backup"
  value        = module.passwords.backup_password
  key_vault_id = azurerm_key_vault.main.id
}
```

### Integration with AWS Secrets Manager

```hcl
module "passwords" {
  source = "./terraform-password-generate"
}

resource "aws_secretsmanager_secret_version" "passwords" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    active  = module.passwords.active_password
    backup  = module.passwords.backup_password
    version = module.passwords.active_password_version
  })
}
```

### Automated Monthly Rotation

Use version strings based on dates:

```bash
# January
terraform apply -var="backup_password_version=2024-01"

# February
terraform apply -var="backup_password_version=2024-02"

# March
terraform apply -var="backup_password_version=2024-03"
```



---

## API Reference

### Commands Reference

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply

# View all outputs
terraform output

# View specific password
terraform output -raw active_password
terraform output -raw backup_password

# View status (non-sensitive)
terraform output password_status

# Destroy all resources
terraform destroy
```



## Additional Documentation

- **[SETUP-GUIDE.md](SETUP-GUIDE.md)** - Step-by-step manual test plan and guide

---

## Requirements

- **Terraform**: >= 1.0
- **Provider**: hashicorp/random ~> 3.0

---

## Security Considerations

### State File Security

⚠️ **IMPORTANT**: Terraform state files contain passwords in plaintext.

**Best Practices:**
- Use remote state with encryption (S3, Azure Storage, Terraform Cloud)
- Restrict state file access with IAM/RBAC
- Enable state file versioning
- Never commit state files to version control

### Version Control

The included `.gitignore` prevents committing:
- `*.tfstate` files
- `*.tfvars` files
- `.terraform` directories

---

## Support

For issues or questions:
1. Review the [Troubleshooting](#troubleshooting) section

4. Refer to [Terraform Random Provider Documentation](https://registry.terraform.io/providers/hashicorp/random/latest/docs)

---

## License

This module is provided as-is for use in your projects.

---

## Summary

This module provides a complete solution for dual password management with:

✅ **All Requirements Met**
- Dual password generation
- Selective backup rotation
- Password swapping capability
- Idempotent operations
- Substrate agnostic design
- Maximum 2 applies guarantee
- Operation safety with validation

**Ready for production use!** 🚀
