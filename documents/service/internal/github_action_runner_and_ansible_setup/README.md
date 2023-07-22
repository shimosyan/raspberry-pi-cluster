# Github Action Self-host Runner And Ansible Setup

## サービスの仕様

このサービスは Github Action Self-host Runner を用いることで、内部環境に対して CI/CD を実施できるようにするものです。

Kubernetes を LXC で起動するためには、Proxmox 内に設置されるコンテナの設定ファイル（`/etc/pve/lxc/<コンテナID>.conf`）を書き換える必要があります。

それらを自動化するために、Github Action からコンテナを作成した際に上記作業を実行できる環境を作成します。

[最新の構成図](https://miro.com/app/board/uXjVOnZ07F0=/?moveToWidget=3458764559949216999&cot=14)

![構成図](./diagram.jpg)

- このサービスは外部に公開しない。
- このインスタンスは冗長は特に要求しない。
- 本サービスでは以下のアプリケーションを稼働させる。
  - `github action self-host runner`: Github Action とコネクションを張り、ジョブからコマンドが実行されたら同環境にてコマンドを実行する役割を担う。
  - `ansible`: 他の複数のホストに対して SSH 経由でコマンドを実行する役割を担う。

## LXC の起動

Terraform で作成します。**事前に `/proxmox` 内の Terraform プロジェクトを用意してください。([手順](/proxmox/README.md))**

[/proxmox/container.tf](/proxmox/container.tf) に以下の通りに記載し、`terraform apply` コマンドでデプロイします。

```tf
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
    size    = "8GB"
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
```
