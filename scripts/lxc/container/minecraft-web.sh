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
docker volume create --driver local --opt type=nfs --opt o=addr=192.168.6.21,rw,nfsvers=4 --opt device=:/volume1/proxmox-data/web nfs-web

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

# Minecraft ポータル Web サーバーの設定
http {
        sendfile on;
        tcp_nopush on;
        types_hash_max_size 2048;

        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
        ssl_prefer_server_ciphers on;

        gzip on;

        server {
                listen 80;
                server_name _;

                root /var/html;
                index index.php index.html index.htm;

                location / {
                        try_files \$uri \$uri/ /index.php\$is_args\$args;
                }

                location ~ \.php$ {
                        fastcgi_pass   php-fpm:9000;
                        fastcgi_index  index.php;
                        fastcgi_param  SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
                        include        fastcgi_params;
                }
        }
}
EOF

# Nginx + PHP を実行する
cat <<EOF > /root/docker-compose.yml
version: '3'

services:
  nginx:
    image: nginx:latest
    ports:
      - 8080:80
    volumes:
      - type: bind
        source: /root/nginx.conf
        target: /etc/nginx/nginx.conf
      - type: volume
        source: nfs-web
        target: /var/html

  # PHP-FPM コンテナ
  php-fpm:
    image: php:fpm
    ports:
      - 9000:9000
    volumes:
      - type: volume
        source: nfs-web
        target: /var/html


# Compose の外ですでに作成済みの volume を指定する場合は ture を設定する。
# そうすると、 docker-compose up 時に Compose は volume を作成しようとしません。
# かつ、指定した volume が存在しないとエラーを raise します。
volumes:
  nfs-minecraft:
    external: true
  nfs-proxy:
    external: true
  nfs-web:
    external: true
EOF

docker compose up -d
#docker compose exec nginx "chown -R www-data:www-data /var/html"

echo "1" > $FILE
