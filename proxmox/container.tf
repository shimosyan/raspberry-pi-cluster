resource "proxmox_lxc" "k8s" {
  for_each = local.container

  vmid         = each.value["vmid"]
  hostname     = each.key
  target_node  = each.value["target_node"]
  ostemplate   = var.lxc_os_template
  arch         = "arm64"
  ostype       = "ubuntu"
  unprivileged = each.value["unprivileged"]
  onboot       = each.value["onboot"]
  cores        = each.value["cpu"]
  memory       = each.value["memory"]
  swap         = each.value["swap"]
  password     = var.root_pw
  start        = false # Ansible 側で起動する

  // rootfs を記述しないとクラッシュするので注意
  rootfs {
    storage = "synology-nfs"
    size    = each.value["storage"]
  }

  network {
    name     = "eth0"
    bridge   = "vmbr0"
    firewall = true
    ip       = each.value["ip"]
    gw       = "192.168.6.1"
  }

  nameserver = "192.168.2.1"
}
