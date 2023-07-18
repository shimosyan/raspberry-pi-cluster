# VM VS LXC

## Proxmox で扱える仮想環境の違い

|項目|VM|LXC|
|---|---|---|
|RAM使用量|多い|少ない|
|Cloud-Init|使用できる|使用できない|

## 採用する環境

Raspberry PI で動かすには RAM 使用量の少なさは絶対的な魅力があるため LXC を使用する。
