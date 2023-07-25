#!/bin/bash

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

# Minecraft を実行する
#docker run --rm --name mcserver -d --mount source=nfs-minecraft,target=/data -e MEMORYSIZE='4G' -e TZ='Asia/Tokyo' -e EULA=TRUE -p 25565:25565 -i marctv/minecraft-papermc-server:latest --restart always

# Login Console
#docker exec -it mcserver /bin/bash

# Update Command
#docker pull marctv/minecraft-papermc-server:latest
#docker stop mcserver

