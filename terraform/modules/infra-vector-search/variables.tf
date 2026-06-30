variable "gcp_project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "resource_prefix" {
  type = string
}

variable "network_id" {
  type = string
}

variable "vector_search_psc_ip_self_link" {
  type = string
}

variable "index_display_name" {
  type = string
}

variable "endpoint_display_name" {
  type = string
}

variable "deployed_index_id" {
  type = string
}

variable "deployed_index_display_name" {
  type    = string
  default = "Deployed Vector Search Index"
}

variable "dimensions" {
  type    = number
  default = 768
}

variable "approximate_neighbors_count" {
  type    = number
  default = 10
}

variable "distance_measure_type" {
  type    = string
  default = "DOT_PRODUCT_DISTANCE"
}

variable "leaf_node_embedding_count" {
  type    = number
  default = 1000
}

variable "leaf_nodes_to_search_percent" {
  type    = number
  default = 7
}

variable "min_replica_count" {
  type    = number
  default = 1
}

variable "max_replica_count" {
  type    = number
  default = 1
}

variable "psc_project_allowlist" {
  type    = list(string)
  default = []
}

variable "psc_forwarding_rule_name_suffix" {
  type    = string
  default = "psc-vector-index-fr"
}

variable "labels" {
  type        = map(string)
  description = "Canonical labels applied to label-capable resources"
}
