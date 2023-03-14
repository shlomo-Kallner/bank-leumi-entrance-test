
variable "proxy_ip" {
    type = string
    description = "(optional) the proxy IP through which allow access to the ec2  instance"
    default = "91.231.246.50"
}

variable "MYSQL_ROOT_PASSWORD" {
  sensitive = true
  type = string
}

locals {
  proxy_ip = length(regexall("[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}", var.proxy_ip)) > 0 ? var.proxy_ip : "91.231.246.50"
  proxy_ingress_cidr = "${local.proxy_ip}/32"

  private_ip = "10.181.242.10"
}