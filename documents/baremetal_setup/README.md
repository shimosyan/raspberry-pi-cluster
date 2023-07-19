# Raspberry PI Setup

この環境では Raspberry PI OS Bullseye に準拠しています。

## イメージの書き込み

### アプリケーションのインストール

公式から [Raspberry Pi Imager](https://www.raspberrypi.com/software/) を入手・インストールします。

### OSイメージの書き込み

MicroSD カードを用意し、PCに接続後 Raspberry Pi Imager を起動して次のように設定します。

|項目|選択・設定値|
|---|---|
|OS|Raspberry PI OS Lite ***(64-bit)***|
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

イメージの書き込みが終わったら、Raspberry Pi を起動し LAN に接続します。

そのうち、DHCP 帯に割り当てられるので、そのIPを特定して SSH で接続します。

### Swap の無効化

Raspberry PI で Swap を使うと、MicroSD カードの寿命を減らすだけなので無効化します。

以下のコマンドを実行します。

```sh
sudo dphys-swapfile swapoff
sudo systemctl stop dphys-swapfile
sudo systemctl disable dphys-swapfile
```

### Proxmox のインストール

[公式リポジトリ](https://github.com/pimox/pimox7)の手順を参考に次のとおりにコマンドを入力します。

```sh
sudo -s
curl https://raw.githubusercontent.com/pimox/pimox7/master/RPiOS64-IA-Install.sh > RPiOS64-IA-Install.sh
chmod +x RPiOS64-IA-Install.sh
./RPiOS64-IA-Install.sh
```

プロンプトでは次のように入力します。

途中で、ホスト名や IP アドレスに関する質問が来ますが、[Miro](https://miro.com/app/board/uXjVOnZ07F0=/?share_link_id=250765172883)の構成図通りに IP アドレスをアドレスを指定します。

ここでは、以下の例の通りに入力します。ホスト名や IP アドレスは適宜置き換えてください。

- ホスト名: `raspi-8gb-1`
- IPアドレス: `192.168.6.33`

|Question|Value|
|---|---|
|Enter new hostname|`raspi-8gb-1`|
|Enter new static IP and NETMASK|`192.168.6.33/24`|
|Is 192.168.6.1 the correct gateway ?|`Y`|
|YOU ARE OKAY WITH THESE CHANGES ? YOUR DECLARATIONS ARE CORRECT ? CONTINUE ?|`Y`|
|New password|`root パスワード` `※`|

`※ Proxmox のログインで使用します。すでに Proxmox が立ち上がっている環境がある場合は、こちらと同じものを設定します（管理画面を負荷分散しているためどのノードに当たるかわからなくなるため）`

インストールが終わったら自動で再起動されます。

## Proxmox へのログイン

`https://192.168.6.33:8006/` にアクセスします。

自己署名証明書なのでアクセス時に警告画面がでますが、そのまま気にせすアクセスします。

ログインを求められますが、まずは言語を日本語に設定します。

root アカウントでログインしましょう。

User name に `root` を、Password に先ほど設定したパスワードを入力します。
Realm は `Linux PAM standard authentication` を選択してください。

最後に Login をクリックすれば Proxmox にログインできるはずです。

有効なサブスクリプションがないというアラートが出ますが、気にせず OK で閉じてください。

## 参考資料

- <https://qiita.com/wancom/items/c6b5ca66ab421d696beb>
