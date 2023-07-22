resource "proxmox_lxc" "github_action_runner_and_ansible" {
  vmid         = 102
  hostname     = "github-action-runner-and-ansible"
  target_node  = "raspi-4gb-2"
  ostemplate   = var.lxc_os_template
  arch         = "arm64"
  ostype       = "ubuntu"
  unprivileged = false
  onboot       = true
  cores        = 1
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
    ip       = "192.168.6.67/24"
    gw       = "192.168.6.1"
  }

  nameserver = "192.168.2.1"
}

/*
resource "proxmox_lxc" "k8s" {
  for_each = local.container

  vmid         = each.value["vmid"]
  hostname     = each.value["hostname"]
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
  start        = true # インスタンスをスタートしていないと削除できない Ref. https://github.com/Telmate/terraform-provider-proxmox/issues/801

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

*/
