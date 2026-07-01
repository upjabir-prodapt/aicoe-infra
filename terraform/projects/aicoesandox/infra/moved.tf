# State migration from pre-module layout to modular layout.

moved {
  from = google_workbench_instance.aicoe_vertex_ai_workbench
  to   = module.notebook.google_workbench_instance.workbench_instance
}

moved {
  from = google_bigquery_dataset.aicoe_translation_dataset
  to   = module.bigquery.google_bigquery_dataset.dataset["translation"]
}

moved {
  from = google_bigquery_dataset.aicoe_sales_agent_dataset
  to   = module.bigquery.google_bigquery_dataset.dataset["sales_agent"]
}

moved {
  from = google_bigquery_dataset.contract_management_dataset
  to   = module.bigquery.google_bigquery_dataset.dataset["contract_management"]
}

moved {
  from = google_bigquery_dataset.aicoe_billing_dataset
  to   = module.bigquery.google_bigquery_dataset.dataset["billing"]
}

moved {
  from = google_vertex_ai_index.aicoe_vector_search_index
  to   = module.vector_search.google_vertex_ai_index.vector_search_index
}

moved {
  from = google_vertex_ai_index_endpoint.aicoe_vector_index_endpoint
  to   = module.vector_search.google_vertex_ai_index_endpoint.vector_index_endpoint
}

moved {
  from = google_vertex_ai_index_endpoint_deployed_index.aicoe_vector_deployed_index
  to   = module.vector_search.google_vertex_ai_index_endpoint_deployed_index.vector_deployed_index
}

moved {
  from = google_compute_forwarding_rule.aicoe_psc_vector_index_fr
  to   = module.vector_search.google_compute_forwarding_rule.psc_vector_index_fr
}

moved {
  from = google_compute_region_network_endpoint_group.aicoe_serverless_neg_translation
  to   = module.load_balancer.google_compute_region_network_endpoint_group.serverless_neg["translation"]
}

moved {
  from = google_compute_region_backend_service.aicoe_ilb_translation_be
  to   = module.load_balancer.google_compute_region_backend_service.backend["translation"]
}

moved {
  from = google_compute_region_url_map.aicoe_ilb_url_map
  to   = module.load_balancer.google_compute_region_url_map.url_map["translation"]
}

moved {
  from = google_compute_region_target_https_proxy.aicoe_ilb_https_proxy
  to   = module.load_balancer.google_compute_region_target_https_proxy.https_proxy["translation"]
}

moved {
  from = google_compute_region_ssl_certificate.aicoe_translation_ssl
  to   = module.load_balancer.google_compute_region_ssl_certificate.ssl["translation"]
}

moved {
  from = google_compute_forwarding_rule.aicoe_ilb_forwarding_rule
  to   = module.load_balancer.google_compute_forwarding_rule.forwarding_rule["translation"]
}

moved {
  from = google_secret_manager_secret_version.ssl_certificate
  to   = module.load_balancer.google_secret_manager_secret_version.certificate["translation"]
}

moved {
  from = google_secret_manager_secret_version.ssl_private_key
  to   = module.load_balancer.google_secret_manager_secret_version.private_key["translation"]
}

moved {
  from = google_compute_region_network_endpoint_group.aicoe_serverless_neg_salesagent
  to   = module.load_balancer.google_compute_region_network_endpoint_group.serverless_neg["salesagent"]
}

moved {
  from = google_compute_region_backend_service.aicoe_ilb_salesagent_be
  to   = module.load_balancer.google_compute_region_backend_service.backend["salesagent"]
}

moved {
  from = google_compute_region_url_map.aicoe_ilb_salesagent_url_map
  to   = module.load_balancer.google_compute_region_url_map.url_map["salesagent"]
}

moved {
  from = google_compute_region_target_https_proxy.aicoe_ilb_salesagent_https_proxy
  to   = module.load_balancer.google_compute_region_target_https_proxy.https_proxy["salesagent"]
}

moved {
  from = google_compute_region_ssl_certificate.aicoe_salesagent_ssl
  to   = module.load_balancer.google_compute_region_ssl_certificate.ssl["salesagent"]
}

moved {
  from = google_compute_forwarding_rule.aicoe_ilb_salesagent_forwarding_rule
  to   = module.load_balancer.google_compute_forwarding_rule.forwarding_rule["salesagent"]
}

moved {
  from = google_secret_manager_secret_version.salesagent_ssl_cert
  to   = module.load_balancer.google_secret_manager_secret_version.certificate["salesagent"]
}

moved {
  from = google_secret_manager_secret_version.salesagent_private_key
  to   = module.load_balancer.google_secret_manager_secret_version.private_key["salesagent"]
}

moved {
  from = google_compute_region_network_endpoint_group.aicoe_serverless_neg_aihub
  to   = module.load_balancer.google_compute_region_network_endpoint_group.serverless_neg["aihub"]
}

moved {
  from = google_compute_region_backend_service.aicoe_ilb_aihub_be
  to   = module.load_balancer.google_compute_region_backend_service.backend["aihub"]
}

moved {
  from = google_compute_region_url_map.aicoe_ilb_aihub_url_map
  to   = module.load_balancer.google_compute_region_url_map.url_map["aihub"]
}

moved {
  from = google_compute_region_target_https_proxy.aicoe_ilb_aihub_https_proxy
  to   = module.load_balancer.google_compute_region_target_https_proxy.https_proxy["aihub"]
}

moved {
  from = google_compute_region_ssl_certificate.aicoe_aihub_ssl
  to   = module.load_balancer.google_compute_region_ssl_certificate.ssl["aihub"]
}

moved {
  from = google_compute_forwarding_rule.aicoe_ilb_aihub_forwarding_rule
  to   = module.load_balancer.google_compute_forwarding_rule.forwarding_rule["aihub"]
}

moved {
  from = google_secret_manager_secret_version.aihub_ssl_cert
  to   = module.load_balancer.google_secret_manager_secret_version.certificate["aihub"]
}

moved {
  from = google_secret_manager_secret_version.aihub_private_key
  to   = module.load_balancer.google_secret_manager_secret_version.private_key["aihub"]
}

moved {
  from = google_bigquery_table.agent_telemetry
  to   = module.bigquery.google_bigquery_table.table["sales_agent.agent_telemetry"]
}

moved {
  from = google_bigquery_table.catalog_build_jobs
  to   = module.bigquery.google_bigquery_table.table["sales_agent.catalog_build_jobs"]
}

moved {
  from = google_bigquery_table.chat_history
  to   = module.bigquery.google_bigquery_table.table["contract_management.chat_history"]
}

moved {
  from = google_bigquery_table.chatfeedback
  to   = module.bigquery.google_bigquery_table.table["contract_management.chatfeedback"]
}

moved {
  from = google_bigquery_table.contract
  to   = module.bigquery.google_bigquery_table.table["contract_management.contract"]
}

moved {
  from = google_bigquery_table.contract_type_config
  to   = module.bigquery.google_bigquery_table.table["contract_management.contract_type_config"]
}

moved {
  from = google_bigquery_table.conversation_log
  to   = module.bigquery.google_bigquery_table.table["contract_management.conversation_log"]
}

moved {
  from = google_bigquery_table.cost_attribution
  to   = module.bigquery.google_bigquery_table.table["sales_agent.cost_attribution"]
}

moved {
  from = google_bigquery_table.dlp_mappings
  to   = module.bigquery.google_bigquery_table.table["translation.dlp_mappings"]
}

moved {
  from = google_bigquery_table.extracted_field
  to   = module.bigquery.google_bigquery_table.table["contract_management.extracted_field"]
}

moved {
  from = google_bigquery_table.research_requests
  to   = module.bigquery.google_bigquery_table.table["sales_agent.research_requests"]
}

moved {
  from = google_bigquery_table.translation_costs
  to   = module.bigquery.google_bigquery_table.table["translation.translation_costs"]
}

moved {
  from = google_bigquery_table.translation_jobs
  to   = module.bigquery.google_bigquery_table.table["translation.translation_jobs"]
}

moved {
  from = google_bigquery_table.translation_reviews
  to   = module.bigquery.google_bigquery_table.table["translation.translation_reviews"]
}

moved {
  from = google_bigquery_table.users_feedback
  to   = module.bigquery.google_bigquery_table.table["sales_agent.users_feedback"]
}
