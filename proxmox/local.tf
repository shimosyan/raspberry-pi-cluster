locals {
  container = yamldecode(file("${path.module}/container.yaml"))
}
