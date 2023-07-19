# Proxmox Setup

## アップデート

### リポジトリの設定

左側のサーバーツリーから物理マシンを選択して、ダッシュボードから`アップデート`→`リポジトリ`を開きます。

`APIリポジトリ`の`追加`をクリックします。

リポジトリ追加ウィンドウが開くので `No-Subscription` を選択して追加します。

### アップデートの設定

左側のサーバーツリーから物理マシンを選択して、ダッシュボードから`アップデート`を開きます。

`再表示`ボタンを押すとログイン時と同じく有効なサブスクリプション契約がない旨のメッセージが表示されるものの無視してOKボタンを押します。

すると `apt-get update` 処理がログ画面に表示されます。

ログに `TASK OK` と表示されたら 右上の×ボタンを押して閉じます。

#### もし GPG error が起きたら

リポジトリのキーが `apt` のkeyマネージャーに信頼されていないことが原因です。

Proxmox のダッシュボード右上にある「シェル」を開き、以下のコマンドで登録すれば解決できます。

`KEY_ID` にはエラーテキストにある `NO_PUBKEY` の右側の文字列を使用してください。

```sh
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys KEY_ID
```

### アップデートの実行

左側のサーバーツリーから物理マシンを選択して、ダッシュボードから`アップデート`を開きます。

`アップグレード` ボタンを押すと別ウィンドウが開き、コンソールで `apt-get dist-upgrade` 処理が走り、続行してよいか聞かれるので `y` ボタンを押下。

アップグレードが完了しても自動的にウィンドウは閉じません。自分で閉じます。

カーネル更新がある場合は、再起動が必要です。

リブートコマンドをたたくなり上部メニューの再起動ボタンを押して再起動します。

## パッケージのインストール

iSCSI 用のパッケージをインストールします。

Proxmox のダッシュボード右上にある「シェル」を開き、以下のコマンドを実行します。

```sh
apt install open-iscsi
```

インストールが終わったら Proxmox のダッシュボード右上にある「再起動」ボタンを実行します。