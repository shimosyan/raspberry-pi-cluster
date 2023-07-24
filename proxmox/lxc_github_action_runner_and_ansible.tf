resource "proxmox_lxc" "github_action_runner_and_ansible" {
  # Enable Switch, 1 = true, 0 = false
  count = 1

  vmid         = 102
  hostname     = "github-action-runner-and-ansible"
  target_node  = "raspi-4gb-2"
  ostemplate   = var.lxc_os_template_ubuntu
  arch         = "arm64"
  ostype       = "ubuntu"
  unprivileged = false
  onboot       = true
  cores        = 1
  memory       = 512 # 512MB ないと Ansible が動かない
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
