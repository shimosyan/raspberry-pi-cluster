#!/bin/bash

if [ $# -ne 1 ]; then
  echo "実行するには1個の引数が必要です。対象の VM ID を指定してください。" 1>&2
  exit 1
fi

CONFIG_FILE="/etc/pve/lxc/$1.conf"

if [ ! -f $CONFIG_FILE ]; then
  echo "ファイルが見つかりません。 $CONFIG_FILE"
  exit 1;
fi

echo "ファイルが見つかりました。 $CONFIG_FILE"
