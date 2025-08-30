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
docker volume create --driver local --opt type=nfs --opt o=addr=192.168.6.21,rw,nfsvers=4 --opt device=:/volume1/proxmox-data/minecraft nfs-minecraft
docker volume create --driver local --opt type=nfs --opt o=addr=192.168.6.21,rw,nfsvers=4 --opt device=:/volume1/proxmox-data/proxy nfs-proxy
docker volume create --driver local --opt type=nfs --opt o=addr=192.168.6.21,rw,nfsvers=4 --opt device=:/volume1/proxmox-data/buckup nfs-buckup

# Minecraft を実行する
# Ref. https://qiita.com/rokuosan/items/4ebeda13d19091b8d29d
cat <<EOF > /root/docker-compose.yml
services:
  # BungeeCord
  proxy:
    image: itzg/bungeecord
    ports:
      - 54621:25577/tcp
      - 25577:25577/udp
    tty: true
    stdin_open: true
    restart: always
    # データ永続化
    volumes:
      - type: volume
        source: nfs-proxy
        target: /server
    environment:
      TYPE: "BUNGEECORD"
      MEMORY: "512M"

  # Paper
  server:
    image: itzg/minecraft-server
    ports:
      - 22233:25565/tcp
      - 25565:25565/udp
    dns:
      - 1.1.1.1
      - 8.8.8.8
    environment:
      EULA: "TRUE"
      TYPE: "PAPER"
      ENABLE_QUERY: "true"
      ENABLE_STATUS: "true"
      OPS: shimosyan
      TZ: Asia/Tokyo
      MEMORY: 4G
      ONLINE_MODE: "false" # BungeeCordを使うのでfalseにしています
      MAX_TICK_TIME: -1
    tty: true
    stdin_open: true
    # データの永続化
    volumes:
      - type: volume
        source: nfs-minecraft
        target: /data
    restart: always

  # バックアップ
  backup:
    image: itzg/mc-backup
    environment:
      - TZ=Asia/Tokyo
      - INITIAL_DELAY=2m
      - BACKUP_INTERVAL=4h
      - PRUNE_BACKUPS_DAYS=3
    volumes:
      - type: volume
        source: nfs-buckup
        target: /backups
      - type: volume
        source: nfs-minecraft
        target: /data
    network_mode: "service:server"

# Compose の外ですでに作成済みの volume を指定する場合は ture を設定する。
# そうすると、 docker-compose up 時に Compose は volume を作成しようとしません。
# かつ、指定した volume が存在しないとエラーを raise します。
volumes:
  nfs-minecraft:
    external: true
  nfs-proxy:
    external: true
  nfs-buckup:
    external: true
EOF

sleep 60

docker compose up -d

echo "1" > $FILE
