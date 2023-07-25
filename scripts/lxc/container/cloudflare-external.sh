#!/bin/bash

if [ $# -ne 1 ]; then
  echo "実行するには1個の引数が必要です。Cloudflare tunnel の Token を指定してください。" 1>&2
  exit 1
fi

TOKEN=$1

# 必要なパッケージのインストール
apt update
apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# nginx の設定を作成
cat <<EOF > /root/nginx.conf
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
        worker_connections 768;
        # multi_accept on;
}

stream {
    server {
        listen 25565;
        proxy_pass 192.168.6.69:54621;
    }
}

EOF

# nginx を起動
docker run --name nginx -d -v /root/nginx.conf:/etc/nginx/nginx.conf --restart always -p 80:80 -p 81:81 nginx:latest

# cloudflared を起動
docker run --name cloudflare -d --restart always cloudflare/cloudflared:latest tunnel --no-autoupdate run --token $TOKEN
