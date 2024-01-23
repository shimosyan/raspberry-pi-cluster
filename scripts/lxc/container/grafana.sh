#!/bin/bash

cd `dirname $0`

FILE="/root/.setup_done"

# このスクリプトが一度でも実行されたログがあるなら処理を継続しない
if [ -e $FILE ]; then
  echo "Setup Done File exists."
  exit 0;
fi

apt update

# Docker のインストール
apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# NAS をマウントする
# Ref. https://redj.hatenablog.com/entry/2019/04/11/011302
docker volume create --driver local --opt type=nfs --opt o=addr=192.168.6.21,rw,nfsvers=4 --opt device=:/volume1/proxmox-data/grafana nfs-grafana

cat <<EOF > /root/docker-compose.yml
version: '3'

services:
  grafana:
    image: grafana/grafana-enterprise
    container_name: grafana
    restart: unless-stopped
    ports:
      - '3000:3000'
    volumes:
      - type: volume
        source: nfs-grafana
        target: /var/lib/grafana
volumes:
  nfs-grafana:
    external: true
EOF

docker compose up -d

echo "1" > $FILE
