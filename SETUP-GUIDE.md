# 🧪 Manual Test Plan & Use Cases

Perform these operations one by one to verify all module functionality and safety constraints.

---

## 📋 Pre-Requisites

Ensure you have a `terraform.tfvars` file. We will modify this file for each test case.

---

## Use Case 1: Initial Setup (Fresh State)

**Goal**: Establish a baseline with version 1 passwords.

1.  **Edit `terraform.tfvars`**:
    ```hcl
    active_password_version = "v1"
    backup_password_version = "v1"
    swap_passwords = false
    ```

2.  **Run Command**:
    ```bash
    terraform apply -auto-approve
    ```

3.  **Verify**:
    - `active_password_version` = "v1"
    - `swapped` = false

---

## Use Case 2: Idempotency Check

**Goal**: Ensure running apply again does NOT change anything.

1.  **Edit `terraform.tfvars`**:
    *(Keep same as Use Case 1)*

2.  **Run Command**:
    ```bash
    terraform apply
    ```

3.  **Verify**:
    - Output should say: `No changes. Your infrastructure matches the configuration.`

---

## Use Case 3: Rotate Backup Password

**Goal**: Generate a NEW backup password (v2).

1.  **Edit `terraform.tfvars`**:
    ```hcl
    active_password_version = "v1"
    backup_password_version = "v2"  # <-- CHANGED
    swap_passwords = false
    ```

2.  **Run Command**:
    ```bash
    terraform apply -auto-approve
    ```

3.  **Verify**:
    - `backup_password_version` = "v2"
    - Active password did NOT change.

---



## Use Case 4: Correct Workflow - Step 1 (Rotate)

**Goal**: Prepare v3 password (Rotate first).

1.  **Edit `terraform.tfvars`**:
    ```hcl
    active_password_version = "v1"
    backup_password_version = "v3"  # <-- Rotate only
    swap_passwords = false          # <-- No Swap yet
    ```

2.  **Run Command**:
    ```bash
    terraform apply -auto-approve
    ```

3.  **Verify**:
    - `backup_password_version` = "v3"

---

## Use Case 5: Correct Workflow - Step 2 (Swap)

**Goal**: Promote the new v3 password to Active.

1.  **Edit `terraform.tfvars`**:
    ```hcl
    active_password_version = "v1"
    backup_password_version = "v3"
    swap_passwords = true           # <-- Now Swap
    ```

2.  **Run Command**:
    ```bash
    terraform apply -auto-approve
    ```

3.  **Verify**:
    - `passwords_swapped` = true
    - Old backup (v3) is now the **Active** password.

---

## Use Case 6: Swap Back (Reset)

**Goal**: Revert positions.

1.  **Edit `terraform.tfvars`**:
    ```hcl
    active_password_version = "v1"
    backup_password_version = "v3"
    swap_passwords = false          # <-- Swap false
    ```

2.  **Run Command**:
    ```bash
    terraform apply -auto-approve
    ```

3.  **Verify**:
    - `passwords_swapped` = false


