variable "admin_username" {
  type = string
  description = "Administrator user name for virtual machine"
  default = "popeye"
}

variable "admin_password" {
  type = string
  description = "Password must meet Azure complexity requirements"
  # default = "hunter2" # yeah, right...
}

variable "prefix" {
  type = string
  default = "mqtt"
}

variable "tags" {
  type = map

  default = {
    Environment = "TGS"
    Team = "Cordeiro"
    Dept = "Photonics"
    Infra = "Mqtt"
  }
}

# AU = Australia
# NY = New York

variable "location" {
  type = map
  default = {
    au = "australiaeast"
    ny = "eastus"
  }
}
