# Raspberry PI Setup

## イメージの書き込み

### アプリケーションのインストール

公式から [Raspberry Pi Imager](https://www.raspberrypi.com/software/) を入手・インストールします。

### OSイメージの書き込み

MicroSD カードを用意し、PCに接続後 Raspberry Pi Imager を起動して次のように設定します。

|項目|選択・設定値|
|---|---|
|OS|Raspberry PI OS Lite **(64-bit)**|
|ストレージ|挿入したMicroSDを選択|

続いて、画面右下の歯車マークのボタンから次のように詳細な設定を実施します。

|項目|選択・設定値|
|---|---|
|ホスト名|raspi-`n`gb-`n`.local|
|SSH を有効化する|ON|
|パスワード認証を使う|OFF|
|公開鍵認証のみ使う|ON|
|公開鍵|1Passwordで生成した公開鍵|
|ユーザー名とパスワードを設定する|ON|
|ユーザー名|*1Passwordに保管*|
|パスワード|1Passwordで生成したパスワード|
|Wi-Fiを設定する|OFF|
|ロケールを設定する|ON|
|タイムゾーン|`Asia/Tokyo`|
|キーボードレイアウト|`JP`|

ここまで終わったら、MicroSD カードへの書き込みを実行します。

## OS の設定

### ネットワークの設定

イメージの書き込みが終わったら、Raspberry Piを起動しLANGに接続します。

そのうち、DHCP帯に割り当てられるので、そのIPを特定してSSHで接続します。

接続できたら、まずはIPアドレスを設定します。

[Miro](https://miro.com/app/board/uXjVOnZ07F0=/?share_link_id=250765172883)の構成図通りにIPアドレスをアドレスを指定します。

L3スイッチはDNSサーバー機能を持たないため、DNS サーバーはルーターを指定します。

```sh:/etc/dhcpcd.conf
interface eth0
static ip_address=192.168.6.x/24
static routers=192.168.6.1
static domain_name_servers=192.168.2.1
```

### ホストの設定

続いて、ホストを設定します。hosts の IP アドレスを先の手順で IP アドレスを固定したものに書き換えます。

```sh:/etc/hosts
#127.0.1.1      raspi-8gb-1
192.168.6.n     raspi-8gb-1
```

### 再起動
