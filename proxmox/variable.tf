variable "root_pw" {
  type = string
}

variable "lxc_os_template" {
  type    = string
  default = "synology-nfs:vztmpl/ubuntu-jammy-arm64-default.tar.xz"
}
