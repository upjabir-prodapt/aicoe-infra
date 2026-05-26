project = "svcmgmtops"
envname = "sandbox"
region = "europe-west1"
gcp_apis_required =[

    "aiplatform.googleapis.com",               # Vertex AI API - models, endpoints, pipelines, training
    "bigquery.googleapis.com",                 # BigQuery API - datasets, tables, jobs
    
]
