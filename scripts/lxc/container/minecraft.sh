#!/bin/bash

apt update
apt install -y nfs-common cifs-utils

# NAS のマウント設定
mkdir -p /mnt/nas
mount -t nfs 192.168.6.21:/volume1/proxmox-data /mnt/nas
echo "192.168.6.21:/volume1/proxmox-data /mnt/nas nfs defaults 0 0" >> /etc/fstab

# Docker のインストール

