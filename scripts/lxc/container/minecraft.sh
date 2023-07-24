#!/bin/bash

apt update
apt install -y nfs-common cifs-utils

# NAS のマウント設定
mkdir -p /mnt/nas
mount -t nfs 192.168.6.21:/volume1/proxmox-data /mnt/nas

# 自動マウントの設定
echo "192.168.6.21:/volume1/proxmox-data /mnt/nas nfs defaults 0 0" >> /etc/fstab

# 自動アンマウントの設定
cat <<EOF > /etc/rc6.d/K99_script
#!/bin/bash

unmount /mnt/nas
EOF

chmod +x /etc/rc6.d/K99_script


# Docker のインストール

