project = "ai-product-security-dev"
envname = "dev"
region = "europe-west1"
gcp_apis_required =[

    "aiplatform.googleapis.com",               # Vertex AI API - models, endpoints, pipelines, training
    "notebooks.googleapis.com",                # Vertex AI Workbench - managed notebook instances    
   
]
artifact_format = "docker"