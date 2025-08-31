resource "proxmox_lxc" "grafana" {
  # Enable Switch, 1 = true, 0 = false
  count = 1
  force = false

  vmid         = 107
  hostname     = "grafana"
  target_node  = "raspi-4gb-1"
  ostemplate   = var.lxc_os_template_ubuntu
  arch         = "arm64"
  ostype       = "ubuntu"
  unprivileged = false # NFS のマウントで必要
  onboot       = true
  cores        = 2
  memory       = 3072 # 試験的にRAMを3GBに設定
  swap         = 0
  password     = var.root_pw
  start        = true # インスタンスをスタートしていないと削除できない Ref. https://github.com/Telmate/terraform-provider-proxmox/issues/801

  // rootfs を記述しないとクラッシュするので注意
  rootfs {
    storage = "synology-nfs"
    size    = "32G"
  }

  network {
    name     = "eth0"
    bridge   = "vmbr0"
    firewall = true
    ip       = "192.168.6.72/24"
    gw       = "192.168.6.1"
  }

  nameserver = "192.168.2.1"
}
