# Proxmox Terraform

## 公式リファレンス

<https://registry.terraform.io/providers/Telmate/proxmox/latest/docs>

## セットアップ方法

他の環境でこれを使用する場合は以下の事前設定が必要です。

- `.tfstate` ファイルを設置する宛先の AWS S3 の作成
  - 及びそれを操作するための IAM ユーザーとアクセスキー設定
- `./main.tf` ファイル内の書き換え
  - 上記 S3 のバケットの指定
  - 宛先の Proxmox サーバーの URL
- GitHub リポジトリに Github Action 向けのシークレットの登録
  - `PM_API_TOKEN_ID`: Proxmox の API キー
  - `PM_API_TOKEN_SECRET`: Proxmox の API シークレット
  - `CF_ACCESS_CLIENT_ID`: Cloudflare Access Service Token のクライアント ID
  - `CF_ACCESS_CLIENT_SECRET`: Cloudflare Access Service Token のクライアントシークレット
  - `AWS_ACCESS_KEY_ID`: 上記 AWS S3 バケットの操作が可能な IAM ユーザーのアクセスキー
  - `AWS_SECRET_ACCESS_KEY`: 上記 AWS S3 バケットの操作が可能な IAM ユーザーのアクセスシークレット
  - `DEFAULT_ROOT_PW`: Terraform で作成する LXC コンテナの Root パスワード

## IAM ユーザーの権限

以下のポリシーの作成・アタッチが必要です。

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::<bucket_name>/*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:ListAllMyBuckets"
            ],
            "Resource": "*"
        }
    ]
}
```

## ローカルで使用する方法

ローカルで作業するには以下の手順が必要です。

- 上記 AWS IAM ユーザーの AWS CLI 設定
  - コンソール上で動かせるようにしておきます。
- `secret.sh.sample` のコピー・編集（後述）
- Terraform 初期化（後述）

### シークレットファイルの作成

以下のコマンドを実行して、シークレットが格納されるファイルを作成します。`secret.sh` のファイル名であれば git の追跡はされません。

```sh
cp ./secret.sh.sample secret.sh
```

`secret.sh` に用意した各シークレットを入力し、以下のコマンドの実行でロードできます。

```sh
source secret.sh
```

### Terraform 初期化

以下のコマンドを実行します。

```sh
terraform init
```
