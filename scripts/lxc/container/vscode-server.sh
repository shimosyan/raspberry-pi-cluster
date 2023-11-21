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
curl -L https://go.microsoft.com/fwlink/?LinkID=760868 -o vscode.deb
apt install ./vscode.deb

# VScode サーバーの起動
cat <<EOF > /etc/systemd/system/vscode-server.service
[Unit]
Description = VSCode Server Service

[Service]
ExecStart = /usr/bin/code serve-web --without-connection-token
Restart = always # 常に再起動
User = kusuke # root以外で実行する場合ユーザ名をセット、rootの場合この行を消す

[Install]
WantedBy = multi-user.target
EOF

systemctl start vscode-server
systemctl enable vscode-server

echo "1" > $FILE
