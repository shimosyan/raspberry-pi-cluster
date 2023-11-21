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

http {
        sendfile on;
        tcp_nopush on;
        types_hash_max_size 2048;

        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
        ssl_prefer_server_ciphers on;

        gzip on;

        # proxmox サーバー向けの設定
        upstream proxmox {
                ip_hash;
                server 192.168.6.33:8006;
                server 192.168.6.34:8006;
                server 192.168.6.35:8006;
                server 192.168.6.36:8006;
        }

        server {
                listen 80;
                server_name _;
                location / {
                        proxy_set_header Host \$http_host;
                        proxy_pass https://proxmox;

                        # Webコンソールが動作するよう以下も記述する
                        proxy_http_version 1.1;
                        proxy_set_header Connection \$http_connection;
                        proxy_set_header Origin http://\$host;
                        proxy_set_header Upgrade \$http_upgrade;
                }
        }

        # NAS 向けの設定
        server {
                listen 81;
                server_name _;
                location / {
                        proxy_set_header Host \$http_host;
                        proxy_pass https://192.168.6.21:5101;

                        proxy_http_version 1.1;
                        proxy_set_header Connection \$http_connection;
                        proxy_set_header Origin http://\$host;
                        proxy_set_header Upgrade \$http_upgrade;
                }
        }

        # VScode 向けの設定
        server {
                listen 82;
                server_name _;
                location / {
                        proxy_set_header Host \$http_host;
                        proxy_pass https://192.168.6.71:8000;

                        proxy_http_version 1.1;
                        proxy_set_header Connection \$http_connection;
                        proxy_set_header Origin http://\$host;
                        proxy_set_header Upgrade \$http_upgrade;
                }
        }
}
EOF

sleep 60

# nginx を起動
docker run --name nginx -d -v /root/nginx.conf:/etc/nginx/nginx.conf --restart always -p 80:80 -p 81:81 -p 82:82 nginx:latest

# cloudflared を起動
docker run --name cloudflare -d --restart always cloudflare/cloudflared:latest tunnel --no-autoupdate run --token $TOKEN
