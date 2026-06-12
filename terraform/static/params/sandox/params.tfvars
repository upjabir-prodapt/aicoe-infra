project = "aicoe"
envname = "sandox"
region = "europe-west1"
gcp_apis_required =[

    "aiplatform.googleapis.com",               # Vertex AI API - models, endpoints, pipelines, training
    "storage.googleapis.com",                  # Cloud storae API
    
]
artifact_format = "docker"