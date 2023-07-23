#!/bin/bash

if [ $# -ne 2 ]; then
  echo "実行するには2個の引数が必要です。対象の VM ID と CONTAINER SCRIPT NAMEを指定してください。" 1>&2
  exit 1
fi

LXC_VM_ID=$1
LXC_SCRIPT_NAME=$2

CONFIG_FILE="/etc/pve/lxc/$LXC_VM_ID.conf"

if [ ! -f $CONFIG_FILE ]; then
  echo "[$LXC_VM_ID] $(date): File Not Found. => $CONFIG_FILE\n"
  exit 0;
fi

echo "[$LXC_VM_ID] $(date): ファイルが見つかりました。設定を追記します。 => $CONFIG_FILE\n"

if ! grep -q "features" $CONFIG_FILE; then
  pct set $LXC_VM_ID --features fuse=1,keyctl=1,nesting=1
fi

if ! grep -q "lxc.apparmor.profile" $CONFIG_FILE; then
  echo "lxc.apparmor.profile: unconfined" >> $CONFIG_FILE
fi

if ! grep -q "lxc.cap.drop" $CONFIG_FILE; then
  echo "lxc.cap.drop:" >> $CONFIG_FILE
fi

if ! grep -q "lxc.cgroup.devices.allow" $CONFIG_FILE; then
  echo "lxc.cgroup.devices.allow: a" >> $CONFIG_FILE
fi

if ! grep -q "lxc.mount.auto" $CONFIG_FILE; then
  echo "lxc.mount.auto: proc:rw sys:rw" >> $CONFIG_FILE
fi

#コンテナを一旦起動
pct start $LXC_VM_ID

# カーネル参照先のディレクトリを作成
pct exec $LXC_VM_ID -- mkdir -p /usr/lib/modules

# マウントを追加
if ! grep -q "lxc.mount.entry" $CONFIG_FILE; then
  echo "lxc.mount.entry: /usr/lib/modules usr/lib/modules none bind 0 0" >> $CONFIG_FILE
fi

# コンテナを再起動
pct reboot $LXC_VM_ID

# セットアップスクリプトを送信
pct push $LXC_VM_ID ~/scripts/container/$LXC_SCRIPT_NAME.sh /root/setup.sh
pct exec $LXC_VM_ID sh /root/setup.sh
