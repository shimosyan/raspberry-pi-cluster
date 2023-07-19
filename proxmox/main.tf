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

resource "proxmox_lxc" "basic" {
  target_node  = "raspi-8gb-1"
  hostname     = "lxc-basic"
  ostemplate   = "synology-nfs:vztmpl/ubuntu-jammy-arm64-default.tar.xz"
  unprivileged = true
  memory       = 128

  // Terraform will crash without rootfs defined
  rootfs {
    storage = "synology-nfs"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
  }
}

