# raspberry-pi-cluster

Raspberry PI Cluster による自宅サーバーの運用リポジトリです。

## 目次

- [baremetal_setup](./baremetal_setup/README.md): 素の Raspberry PI を構築して Proxmox をインストール、起動するまでの手順です。
- Proxmox
  - [proxmox_setup](./proxmox_setup/README.md): 台数関わらず、Proxmox のインストールが終わったら実施する手順です。
  - [cluster_setup](./proxmox_setup/cluster_setup/README.md): 1つ目の Proxmox からクラスターを構築する手順です。
  - [join_cluster](./proxmox_setup/join_cluster/README.md): 2つ目以降の Proxmox を既存のクラスターに追加する手順です。
