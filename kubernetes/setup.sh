#!/bin/bash

FILE="/root/.k8s_setup_done"

# このスクリプトが一度でも実行されたログがあるなら処理を継続しない
if [ -e $FILE ]; then
  echo "Setup Done File exists."
  exit 0;
fi

# k8s をセットアップする

# ログを残す
echo "1" > $FILE
