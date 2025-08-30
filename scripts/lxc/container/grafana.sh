#!/bin/bash

cd `dirname $0`

FILE="/root/.setup_done"

# このスクリプトが一度でも実行されたログがあるなら処理を継続しない
if [ -e $FILE ]; then
  echo "Setup Done File exists."
  exit 0;
fi

# Timezone の変更
sudo timedatectl set-timezone Asia/Tokyo

# Cron 再起動
service cron restart

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
docker volume create --driver local --opt type=nfs --opt o=addr=192.168.6.21,rw,nfsvers=4 --opt device=:/volume1/proxmox-data/grafana-influxdb nfs-influxdb

cat <<EOF > /root/docker-compose.yml
services:
  influxdb:
    image: influxdb
    container_name: influxdb
    restart: always
    volumes:
      - type: volume
        source: nfs-influxdb
        target: /var/lib/influxdb2
    ports:
      - 8086:8086
      - 8083:8083

  grafana:
    image: grafana/grafana-enterprise
    container_name: grafana
    restart: always
    depends_on:
      - influxdb
    ports:
      - '3000:3000'
    volumes:
      - type: volume
        source: nfs-grafana
        target: /var/lib/grafana
volumes:
  nfs-grafana:
    external: true
  nfs-influxdb:
    external: true
EOF

docker compose up -d

## aiseg2-influxdb-forwarder

git clone https://github.com/shimosyan/aiseg2-influxdb-forwarder.git
cd aiseg2-influxdb-forwarder

cp .env.example .env

echo ".env を設定してください。設定が終わったら下記コマンドを実行してください。"
echo "cd aiseg2-influxdb-forwarder && docker compose up -d"

echo "1" > $FILE

#
# 初回インストール後は aiseg2-influxdb の設定・起動・動作確認を実施し、influxdb と grafana の設定を実施すること
#
