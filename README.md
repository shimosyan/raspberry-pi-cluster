# raspberry-pi-cluster

Raspberry PI Cluster による自宅サーバーの運用リポジトリです。

各マニュアルから備忘録まで含みます。

## 注意事項

本リポジトリに記載の資料は[構成図](https://miro.com/app/board/uXjVOnZ07F0=/?share_link_id=902050965289)と対になっています。記述に齟齬がある場合は、本リポジトリではなく構成図を優先します。

## ドキュメント目次

本環境を構築するために必要な手順をまとめた資料です。

`(memo)` と付与されているものは本手順とは関係がない参考資料となります。

- [baremetal_setup](/documents/baremetal_setup/README.md): 素の Raspberry PI を構築して Proxmox をインストール、起動するまでの手順です。
- Proxmox
  - [proxmox_setup](/documents/proxmox_setup/README.md): 台数関わらず、Proxmox のインストールが終わったら実施する手順です。
  - [cluster_setup](/documents/proxmox_setup/cluster_setup/README.md): 1つ目の Proxmox からクラスターを構築する手順です。
  - [join_cluster](/documents/proxmox_setup/join_cluster/README.md): 2つ目以降の Proxmox を既存のクラスターに追加する手順です。
- GuestOS
  - [vm_vs_lxc](./documents/guest_os/vm_vs_lxc/README.md): Virtual Machine か Linux Containers どちらに優位性があるかをまとめた資料です。
  - Virtual Machine
    - ***(memo)*** [manual_setup](/documents/guest_os/virtual_machine_setup/manual_setup/README.md): Proxmox 上で仮想マシンを手動でセットアップ手順です。
    - ***(memo)*** [cloud_init_setup](/documents/guest_os/virtual_machine_setup/cloud_init_setup/README.md): Proxmox 上で仮想マシンを Cloud-Init を使用してセットアップ手順です。
  - Linux Containers
    - [linux_container_initialize](/documents/guest_os/linux_container/linux_container_initialize/README.md): LXC のセットアップ準備手順です。
- Service
  - ここから先の資料は、Proxmox 上に展開されたServiceに関する資料となります。
  - Internal
    - [internal_cloudflare_tunnel_setup](/documents/service/internal/internal_cloudflare_tunnel_setup/README.md): LXC を使用して Proxmox 及び NAS など内部サービスを Cloudflare Tunnel 経由で外部公開する方法です。
    - [github_action_runner_and_ansible_setup](/documents/service/internal/github_action_runner_and_ansible_setup/README.md): Proxmox のホストを操作するための Github Action Self-host Runner と Ansible のセットアップ方法です。
