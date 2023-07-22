#!/bin/bash

if [ $# -ne 1 ]; then
  echo "実行するには1個の引数が必要です。対象の VM ID を指定してください。" 1>&2
  exit 1
fi

LXC_VM_LIST=$1

for LXC_VM_ID in `echo "$LXC_VM_LIST" | tr "," "\n"`
do
  CONFIG_FILE="/etc/pve/lxc/$LXC_VM_ID.conf"

  if [ ! -f $CONFIG_FILE ]; then
    echo "[$LXC_VM_ID] $(date): File Not Found. => $CONFIG_FILE\n"
    continue
  fi

  echo "[$LXC_VM_ID] $(date): ファイルが見つかりました。設定を追記します。 => $CONFIG_FILE\n"

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

  # コンテナを起動
  pct start $LXC_VM_ID

  # セットアップスクリプトを送信
  pct push $LXC_VM_ID ./setup.sh /root/setup.sh
  pct exec $LXC_VM_ID sh /root/setup.sh
done
