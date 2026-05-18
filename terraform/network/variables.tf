variable "project" {}
variable "region" {}
variable "envname" {}
variable "aicoe_subnet_cidr_range" {}
# variable "aicoe_proxy_subnet_cidr_range" {}
variable "aicoe_static_ilb_ip" {}
variable "aicoe_static_vxaiwb_ip" {
    default = null
}
variable "aicoe_static_ilb_salesagent_ip" {}

