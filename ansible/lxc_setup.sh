#!/bin/bash

if [ $# -ne 2 ]; then
  echo "実行するには2個の引数が必要です。対象の VM ID と RES ID を指定してください。" 1>&2
  exit 1
fi

LXC_VM_ID=$1
LXC_RES_ID=$2

echo "LXC_VM_ID = $LXC_VM_ID, LXC_RES_ID = $LXC_RES_ID"

CONFIG_FILE="/etc/pve/lxc/$LXC_VM_ID.conf"

if [ ! -f $CONFIG_FILE ]; then
  echo "[$LXC_VM_ID] $(date): File Not Found. => $CONFIG_FILE\n"
  exit 0;
fi

# LXC_RES_ID からアンダースコアで分割し、1つ目を SCRIPT NAME として使用する
SPLIT=(${LXC_RES_ID//_/ })

SCRIPT_NAME=${SPLIT[0]}

echo "SCRIPT_NAME = $SCRIPT_NAME"

# /root/scripts/host に該当するファイルが見つかれば、そちらに処理を実行し終了する。
HOST_SCRIPT_FILE="/root/scripts/host/$SCRIPT_NAME.sh"

if [ -e $HOST_SCRIPT_FILE ]; then
  $HOST_SCRIPT_FILE $LXC_VM_ID $SCRIPT_NAME
  exit 0;
fi

# ~/scripts/container に該当するファイルが見つかれば、 LXC に転送して実行する。
CONTAINER_SCRIPT_FILE="/root/scripts/container/$SCRIPT_NAME.sh"

if [ -e $CONTAINER_SCRIPT_FILE ]; then
  # セットアップスクリプトを送信
  pct push $LXC_VM_ID /root/scripts/container/$SCRIPT_NAME.sh /root/setup.sh

  pct exec $LXC_VM_ID chmod +x /root/setup.sh
  pct exec $LXC_VM_ID /root/setup.sh
fi
