variable "root_pw" {
  type = string
}

variable "lxc_os_template_ubuntu" {
  type    = string
  default = "synology-nfs:vztmpl/ubuntu-jammy-arm64-default.tar.xz"
}

variable "lxc_os_template_debian" {
  type    = string
  default = "synology-nfs:vztmpl/debian-bullseye-arm64-default.tar.xz"
}
