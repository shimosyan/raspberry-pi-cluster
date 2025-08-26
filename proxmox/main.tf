/*
  terraform 定義
*/
terraform {
  required_version = ">= 1.0.0"

  /*
    .tfstate は AWS S3 に保存すること
  */
  backend "s3" {
    bucket  = "terraform.cube-unit.net"
    region  = "ap-northeast-1"
    key     = "raspi-cluster/proxmox/terraform.tfstate"
    encrypt = true
  }

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc04"
    }
  }
}

provider "proxmox" {
  pm_api_url                  = "https://proxmox.cube-unit.net/api2/json"
  pm_minimum_permission_check = var.pm_minimum_permission_check
}
