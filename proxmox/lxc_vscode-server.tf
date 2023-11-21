resource "proxmox_lxc" "vscode-server" {
  # Enable Switch, 1 = true, 0 = false
  count = 1

  vmid         = 106
  hostname     = "vscode-server"
  target_node  = "raspi-8gb-2"
  ostemplate   = var.lxc_os_template_ubuntu
  arch         = "arm64"
  ostype       = "ubuntu"
  unprivileged = false # NFS のマウントで必要
  onboot       = true
  cores        = 2
  memory       = 512
  swap         = 0
  password     = var.root_pw
  start        = true # インスタンスをスタートしていないと削除できない Ref. https://github.com/Telmate/terraform-provider-proxmox/issues/801

  // rootfs を記述しないとクラッシュするので注意
  rootfs {
    storage = "synology-nfs"
    size    = "8G"
  }

  network {
    name     = "eth0"
    bridge   = "vmbr0"
    firewall = true
    ip       = "192.168.6.71/24"
    gw       = "192.168.6.1"
  }

  nameserver = "192.168.2.1"
}
