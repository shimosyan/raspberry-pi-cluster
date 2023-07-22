locals {
  container_list = yamldecode(file("${path.module}/container.yaml"))

  // container_list から enable が true のものを抽出する
  container = {
    for container, value in local.container_list :
    container => value if value.enable == true
  }
}
