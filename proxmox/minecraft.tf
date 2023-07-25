resource "proxmox_lxc" "minecraft_1" {
  # Enable Switch, 1 = true, 0 = false
  count = 1

  vmid         = 103
  hostname     = "minecraft-1"
  target_node  = "raspi-8gb-1"
  ostemplate   = var.lxc_os_template_ubuntu
  arch         = "arm64"
  ostype       = "ubuntu"
  unprivileged = false # NFS のマウントで必要
  onboot       = true
  cores        = 2
  memory       = 2048
  swap         = 0
  password     = var.root_pw
  start        = false # Ansible 側で起動する

  // rootfs を記述しないとクラッシュするので注意
  rootfs {
    storage = "synology-nfs"
    size    = "8G"
  }

  network {
    name     = "eth0"
    bridge   = "vmbr0"
    firewall = true
    ip       = "192.168.6.68/24"
    gw       = "192.168.6.1"
  }

  nameserver = "192.168.2.1"
}

resource "proxmox_lxc" "minecraft_2" {
  # Enable Switch, 1 = true, 0 = false
  count = 0

  vmid         = 104
  hostname     = "minecraft-2"
  target_node  = "raspi-8gb-1"
  ostemplate   = var.lxc_os_template_ubuntu
  arch         = "arm64"
  ostype       = "ubuntu"
  unprivileged = false # NFS のマウントで必要
  onboot       = true
  cores        = 2
  memory       = 2048
  swap         = 0
  password     = var.root_pw
  start        = false # Ansible 側で起動する

  // rootfs を記述しないとクラッシュするので注意
  rootfs {
    storage = "synology-nfs"
    size    = "8G"
  }

  network {
    name     = "eth0"
    bridge   = "vmbr0"
    firewall = true
    ip       = "192.168.6.69/24"
    gw       = "192.168.6.1"
  }

  nameserver = "192.168.2.1"
}
