#!/bin/bash

cd `dirname $0`

FILE="/root/.setup_done"

# このスクリプトが一度でも実行されたログがあるなら処理を継続しない
if [ -e $FILE ]; then
  echo "Setup Done File exists."
  exit 0;
fi

apt update

# VScode のインストール
apt install -y apt-transport-https curl
curl -L "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-arm64" -o vscode.deb
chown _apt ./vscode.deb
apt install -y ./vscode.deb

# VScode サーバーの起動
cat <<EOF > /etc/systemd/system/vscode-server.service
[Unit]
Description = VSCode Server Service

[Service]
ExecStart = /usr/bin/code --no-sandbox --user-data-dir=/etc/vscode serve-web --host 0.0.0.0 --port 8000 --without-connection-token --accept-server-license-terms
Restart = always # 常に再起動

[Install]
WantedBy = multi-user.target
EOF

systemctl start vscode-server
systemctl enable vscode-server

echo "1" > $FILE
