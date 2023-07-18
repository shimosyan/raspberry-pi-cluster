# raspberry-pi-cluster

Raspberry PI Cluster による自宅サーバーの運用リポジトリです。

各マニュアルから備忘録まで含みます。

## ドキュメント目次

- [baremetal_setup](./documents/baremetal_setup/README.md): 素の Raspberry PI を構築して Proxmox をインストール、起動するまでの手順です。
- Proxmox
  - [proxmox_setup](./documents/proxmox_setup/README.md): 台数関わらず、Proxmox のインストールが終わったら実施する手順です。
  - [cluster_setup](./documents/proxmox_setup/cluster_setup/README.md): 1つ目の Proxmox からクラスターを構築する手順です。
  - [join_cluster](./documents/proxmox_setup/join_cluster/README.md): 2つ目以降の Proxmox を既存のクラスターに追加する手順です。
- GuestOS
  - [vm_vs_lxc](./documents/guest_os/vm_vs_lxc/README.md): Virtual Machine か Linux Containers どちらに優位性があるかをまとめた資料です。
  - Virtual Machine
    - [manual_setup](./documents/guest_os/virtual_machine_setup/manual_setup/README.md): Proxmox 上で仮想マシンを手動でセットアップ手順です。
    - [cloud_init_setup](./documents/guest_os/virtual_machine_setup/cloud_init_setup/README.md): Proxmox 上で仮想マシンを Cloud-Init を使用してセットアップ手順です。
  - Linux Containers
    - [linux_container_setup](./documents/guest_os/linux_container_setup/README.md): LXC のセットアップ手順です。
