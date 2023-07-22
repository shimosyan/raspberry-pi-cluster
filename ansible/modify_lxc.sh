#!/bin/bash

if [ $# -ne 1 ]; then
  echo "実行するには1個の引数が必要です。対象の VM ID を指定してください。" 1>&2
  exit 1
fi

VM_LIST=$1

for VM_ID in `echo "$VM_LIST" | tr "," "\n"`
do
  CONFIG_FILE="/etc/pve/lxc/$VM_ID.conf"

  if [ ! -f $CONFIG_FILE ]; then
    echo "$(date) File Not Found. $CONFIG_FILE\n"
    continue
  fi

  echo "$(date) ファイルが見つかりました。 $CONFIG_FILE\n"
done
