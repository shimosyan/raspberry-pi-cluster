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

ここでは、`raspi-8gb-1` を例に入力します。ホスト名やIPアドレスは適宜置き換えてください。

L3スイッチはDNSサーバー機能を持たないため、DNS サーバーはルーターを指定します。

```sh
#/etc/dhcpcd.conf

interface eth0
static ip_address=192.168.6.17/24
static routers=192.168.6.1
static domain_name_servers=192.168.2.1
```

### ホストの設定

続いて、ホストを設定します。hosts の IP アドレスを先の手順で IP アドレスを固定したものに書き換えます。

```sh
#/etc/hosts

#127.0.1.1      raspi-8gb-1
192.168.6.17    raspi-8gb-1
```

### 再起動

一旦再起動します。

```sh
sudo reboot
```

## Proxmox のインストール

[公式リポジトリ](https://github.com/pimox/pimox7)の手順を参考に次のとおりにコマンドを入力します。

```sh
sudo -s
echo "deb https://raw.githubusercontent.com/pimox/pimox7/master/ dev/" > /etc/apt/sources.list.d/pimox.list
curl https://raw.githubusercontent.com/pimox/pimox7/master/KEY.gpg | apt-key add -
apt update
```

Proxmoxをインストールする。

```sh
apt install pve-manager
```

インストールするアプリケーションは公式手順と異なりますが、[こちらの記事](https://qiita.com/wancom/items/b62ac44e6c9f0d1c4048#64bit%E7%89%88%E3%81%AEraspberrypi-os%E3%82%92%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB%E3%81%99%E3%82%8B)を参考にしました。

途中、インストールに関してプロンプトが立ち上がります。

OpenZFS のライセンス許諾確認画面では`OK`を選択します。

続いて、Postfix の設定画面になりますが、メールの送信は一旦しないため `No configuration` を選択します。

インストールが終わったら再起動します。

## Proxmox の設定

### root パスワードの設定

Proxmox で利用する root ユーザーのパスワードを設定します。

```sh
sudo passwd
```

### Proxmox へのログイン

`https://192.168.0.11:8006/` にアクセスします。

自己署名証明書なのでアクセス時に警告画面がでますが、そのまま気にせすアクセスします。

ログインを求められますが、まずは言語を日本語に設定します。

root アカウントでログインしましょう。

User nameにrootを、Passwordに先ほど設定したパスワードを入力します。
RealmはLinux PAM standard authenticationを選択してください。

最後にLoginをクリックすればProxmoxにログインできるはずです。

有効なサブスクリプションがないというアラートが出ますが、気にせずOKで閉じてください。
