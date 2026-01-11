module "password_mgr" {
  source = "../"
  
  rotate_backup           = true
  swap_passwords          = true
  backup_password_version = "v2"   # ← YE ADD KAR
}
