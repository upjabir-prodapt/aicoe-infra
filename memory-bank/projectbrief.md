# Project Brief: AI CoE Dev Platform GCP Deployment

## Core Requirements & Goals
The objective of this project is to provision a greenfield, production-ready AI platform in GCP for the AI Center of Excellence (CoE). 

The platform:
- Connects workloads securely via private IP networks.
- Enforces an AI Gateway (Apigee) for Vertex AI calls, logging tokens, and rate-limiting.
- Disallows public internet egress (egress-deny-all).
- Reuses the existing `aicoedev-int.colt.net` domains and private TLS certificates.
- Migrates the existing `aicoedev` legacy project to the new `gclt-aicoe-dev-*` estate.

## Scope of Work (Current Phase)
The platform is deployed in numbered, strictly sequential stages (0-bootstrap through 7-apigee-runtime). 
- Stages 0 (Bootstrap), 1 (Org), and 2 (Foundations) have been completed.
- Our current objective is to deploy the remaining stages: **Stage 3 (Network)**, **Stage 4 (Apigee)**, **Stage 5 (Network PSC)**, **Stage 6 (Workloads & Ingress)**, and **Stage 7 (Apigee Runtime)**.
- We must also integrate a critical architecture change for **Model Armor** to move template creation to Stage 7 so it can reach the regional PSC endpoint created in Stage 5, and re-apply Stage 2 to enable the `networkconnectivity.googleapis.com` API needed by Stage 5.
