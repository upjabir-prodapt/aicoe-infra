project = "vegadev-499613"
envname = "dev"
region = "europe-west1"
project_number = "566331480334"
gcp_apis_required =[

    "aiplatform.googleapis.com",               # Vertex AI API - models, endpoints, pipelines, training
    "logging.googleapis.com",                  # Cloud Logging - log ingestion, sinks, routing
    "serviceusage.googleapis.com",             # Service Usage API - enable/disable APIs
    "compute.googleapis.com",                  # Compute Engine API 
    
]