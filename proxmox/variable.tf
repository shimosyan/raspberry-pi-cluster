variable "root_pw" {
  type = string
}

variable "pm_minimum_permission_check" {
  type    = bool
  default = true
}

variable "lxc_os_template_ubuntu" {
  type    = string
  default = "synology-nfs:vztmpl/ubuntu-jammy-arm64-default.tar.xz"
}
