# Virtual Machine Cloud Init Setup

この手順は VM を Cloud-Init でセットアップするための方法です。

本環境では主に LXC を使用するため普段は使用しません。

## OS イメージの追加

### OS イメージのダウンロード

Ubuntu の Cloud-Init 対応イメージを [配布サイト](https://cloud-images.ubuntu.com/)からダウンロード URL を入手します。amd64 は使用できないので注意してください。

本手順では、`Ubuntu 22.04` にあたる `jammy-server-cloudimg-arm64.img` を使用します。

## OS イメージの登録

イメージ URL が入手できたら、Proxmox のいずれかノードから `synology-nfs` ストレージを開きます。

ストレージメニューに `ISOイメージ` があるのでこれを開くと「URL からダウンロード」ボタンがあります。

これをクリックすると、URL の入力ダイアログが表示されるので、先の手順で入手した ISO のダウンロード URL を入力します。

入力が終わったら「クエリURL」をクリックします。ファイル名称などの情報が得られるので、問題なければ「ダウンロード」を実行します。

## VM テンプレートの作成

VM を実行したいノードのシェルを開き、以下のコマンドを順に実行します。

### VM を CPU: 2, RAM: 2GB、ネットワークは `vmbr0` で作成

```sh
qm create 9000 --cores 2 --memory 2048 --net0 virtio,bridge=vmbr0
```

### 作成した VM に対して、QUME エージェント有効、BIOS は `UEFI`、CPU動作モードは `host`、EFI ディスクを新規作成で適用

```sh
qm set 9000 --agent 1 --bios ovmf --cpu host --efidisk0 synology-nfs:1,format=qcow2,efitype=4m,pre-enrolled-keys=1,size=64M
```

### 作成した VM に対して、ダウンロードした OS イメージをインポート

```sh
qm importdisk 9000 /mnt/pve/synology-nfs/template/iso/jammy-server-cloudimg-arm64.img synology-nfs -format qcow2
```

### インポートした OS イメージを VM の `iscsi0` に指定し OS タイプを `Linux`

```sh
qm set 9000 --scsihw virtio-scsi-pci --scsi0 synology-nfs:9000/vm-9000-disk-1.qcow2 --ostype l26
```

### 作成した VM に対して、Cloud-Init ディスクを `iscsi2` に作成

```sh
qm set 9000 --scsi2 synology-nfs:cloudinit
```

### 作成した VM に対して、`iscsi0` をブートディスクに指定

```sh
qm set 9000 --boot c,order=scsi0
```

### 作成した VM に対して、画面出力をシリアルコンソールに指定

```sh
qm set 9000 --serial0 socket --vga serial0
```

### 作成した VM に対して、DNS、キーボード、ユーザー名を指定

```sh
qm set 9000 --nameserver 192.168.2.1 --keyboard ja --ciuser owner
```

### 作成した VM をテンプレート化

```sh
qm template 9000
```

```sh
sudo apt install -y qemu-guest-agent
```

```sh
sudo systemctl start qemu-guest-agent
```

```sh
sudo systemctl enable qemu-guest-agent
```

## VM テンプレートのクローン

これでテンプレートができたので、VM 本体を作成します。

テンプレートに対してクローンを実行すると、設定ウィンドウが立ち上がります。

名称や VM ID はお好みで指定して、モードは `完全クローン` を指定します。

この状態で OK をクリックすると、新規 VM が作成されます。

最後に、作成された VM の「Cloud-Init」ページからユーザーのログインパスワードやIPアドレスを指定します。

## VM の起動

これで VM が起動できます。初回はインストールなどが走るためコンソールから使用できるのは少し時間がかかります。
