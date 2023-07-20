/*
  terraform 定義
*/
terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket  = "terraform.micmnis.net"
    region  = "ap-northeast-1"
    key     = "raspi-cluster/proxmox/terraform.tfstate"
    encrypt = true
  }

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = ">=2.9.14"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://proxmox.micmnis.net/api2/json"
}
