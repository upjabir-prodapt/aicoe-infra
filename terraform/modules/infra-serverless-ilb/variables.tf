###variable "gcp_project_id" {
###  type = string
###}
###
###variable "region" {
###  type = string
###}
###
###variable "resource_prefix" {
###  type = string
###}
###
###variable "network_self_link" {
###  type = string
###}
###
###variable "subnet_self_link" {
###  type = string
###}
###
###variable "services" {
###  type = map(object({
###    cloud_run_service_name = string
###    ip_address             = string
###    certificate_secret     = string
###    private_key_secret     = string
###  }))
###  description = "Map of internal HTTPS load balancer services keyed by service name"
###}
###
###variable "labels" {
###  type        = map(string)
###  description = "Canonical labels applied to label-capable resources"
###}
###

variable "gcp_project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "resource_prefix" {
  type = string
}

variable "network_self_link" {
  type = string
}

variable "subnet_self_link" {
  type = string
}

variable "services" {
  type = map(object({
    cloud_run_service_name = string
    ip_address             = string
    certificate_secret     = string
    private_key_secret     = string
    # Optional override for the https proxy name. Use this when a legacy
    # resource was created with a name that doesn't match the module's
    # default "${resource_prefix}-ilb-${key}-https-proxy" pattern, to avoid
    # a forced replacement. Leave unset for new services.
    https_proxy_name = optional(string)
    # Optional path-based routing rules for this service's url map. When
    # set, the url map gets a host_rule + path_matcher fanning traffic out
    # to other services' backends by path, instead of just a single
    # default_service. Used e.g. by aihub to route /api/sales/* and
    # /api/translation/* to their respective backends.
    path_rules = optional(list(object({
      paths               = list(string)
      backend_service_key = string
      path_prefix_rewrite = optional(string)
    })), [])
  }))
  description = "Map of internal HTTPS load balancer services keyed by service name"
}

variable "labels" {
  type        = map(string)
  description = "Canonical labels applied to label-capable resources"
}