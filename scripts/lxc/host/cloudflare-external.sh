#!/bin/bash

if [ $# -ne 2 ]; then
  echo "実行するには2個の引数が必要です。対象の VM ID と CONTAINER SCRIPT NAMEを指定してください。" 1>&2
  exit 1
fi

LXC_VM_ID=$1
LXC_SCRIPT_NAME=$2

CONFIG_FILE="/etc/pve/lxc/$LXC_VM_ID.conf"

# ~/scripts/container に該当するファイルが見つかれば、 LXC に転送して実行する。
CONTAINER_SCRIPT_FILE="/root/scripts/container/$SCRIPT_NAME.sh"

if [ -e $CONTAINER_SCRIPT_FILE ]; then
  # セットアップスクリプトを送信
  pct push $LXC_VM_ID /root/scripts/container/$SCRIPT_NAME.sh /root/setup.sh

  pct exec $LXC_VM_ID chmod +x /root/setup.sh

  # この cloudflare-external.sh ではスクリプトを起動しない
  #pct exec $LXC_VM_ID /root/setup.sh
fi
