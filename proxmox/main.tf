/*
  terraform 定義
*/
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    proxmox = {
      source  = "shimosyan/proxmox"
      version = ">=1.0.0"
    }
  }
}
