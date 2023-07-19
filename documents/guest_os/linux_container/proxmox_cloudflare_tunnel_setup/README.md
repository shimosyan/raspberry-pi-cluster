# Proxmox Cloudflare Tunnel Setup

このインスタンスは管理目的で使用するためコード管理しません。よって手動で作成します。

## LXC の起動

ダッシュボード右上の「CTを作成」をクリックします。

作成ウィンドウが立ち上がるので、以下の通りに入力します。指定ないものはデフォルト値のままにします。

|カテゴリー|項目|値|
|---|---|---|
|全般|ノード|VM を設置したいノード|
|全般|VM ID|デフォルトのまま|
|全般|名前|`cloudflare-dev`|
|全般|パスワード|root パスワード。1Password に保管|
|テンプレート|ストレージ|[linux_container_initialize](./documents/guest_os/linux_container/linux_container_initialize/README.md) でテンプレートを保存したストレージ|
|テンプレート|テンプレート|[linux_container_initialize](./documents/guest_os/linux_container/linux_container_initialize/README.md) で保存したテンプレート|
|ディスク|ストレージ|NAS を選択|
|ディスク|ディスクサイズ|`8GB`|
|CPU|コア|`1`|
|メモリ|メモリ(MiB)|`256`|
|メモリ|スワップ(MiB)|`0`|
|ネットワーク|IPv4/CIDR|`192.168.6.xxx/24`|
|ネットワーク|ゲートウェイ(IPv4)|`192.168.6.1`|
|DNS|DNSサーバ|`192.168.2.1`|

インスタンスが作成できたら、「開始」をクリックして起動します。

## nginx のインストール

次のコマンドを実行して nginx をインストールします。

```sh
sudo apt update
sudo apt install nginx
```

設定ファイルを編集して、80番ポートを Proxmox にリダイレクトするようにします。

設定ファイルの `http` ブロックを次に置き換えます。

```conf
# /etc/nginx/nginx.conf

http {
        sendfile on;
        tcp_nopush on;
        types_hash_max_size 2048;

        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
        ssl_prefer_server_ciphers on;

        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;

        gzip on;

        # proxmox サーバー向けの設定
        server {
                listen 80;
                server_name _;
                location / {
                        proxy_set_header Host $http_host;
                        proxy_pass https://192.168.6.33:8006;

                        # Webコンソールが動作するよう以下も記述する
                        proxy_http_version 1.1;
                        proxy_set_header Connection $http_connection;
                        proxy_set_header Origin http://$host;
                        proxy_set_header Upgrade $http_upgrade;
                }
        }

        # NAS 向けの設定
        server {
                listen 81;
                server_name _;
                location / {
                        proxy_set_header Host $http_host;
                        proxy_pass https://192.168.6.21:5101;

                        proxy_http_version 1.1;
                        proxy_set_header Connection $http_connection;
                        proxy_set_header Origin http://$host;
                        proxy_set_header Upgrade $http_upgrade;
                }
        }
}
```

追加できたらサービスを再起動・有効化します。

```sh
systemctl restart nginx
systemctl enable nginx
```

### Cloudflare の設定

cURL が必要になることがあるのでインストールします。

```sh
sudo apt install curl
```

Cloudflare Zero Trust をセットアップします。

セットアップが終わったら、[公式リファレンス](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/install-and-setup/tunnel-guide/remote/)を参考に手順を進めます。

ダッシュボードの Access → Tunnels から新規作成します。

arm-64bit 向け Ubuntu(Debian)用のインストールコマンドがあるのでそれをコピペします。

インストールコマンドが成功すると、Cloudflare に自動認識されるので次のページに進みます。

ホストの設定に入るので次のように設定します。

- Public hostname
  - Subdomain: アクセスに使用したいサブドメイン（無料プランでは階層を深くできません）
  - Domain: 所有するドメイン
  - Path: 空白でOK
- Service
  - Type: `HTTP`
  - URL: `localhost:80`

ここまで入力できたら「Save Tunnel」をクリックします。

これで外部からアクセスできるようになっているはずです。

最後に以下のコマンドを実行します。

```sh
systemctl enable cloudflared
```

加えて、Access 機能を使って認証しないと接続できないようにします。

## 参考資料

- <https://qiita.com/honahuku/items/5b7ef71d3b59c4649948>
- <https://zenn.dev/come25136/articles/0952afd78e4922>
