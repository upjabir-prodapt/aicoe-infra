# Apigee Location and Region Reference

This document provides a comprehensive reference of supported locations and regions for Google Cloud Apigee (including Runtime hosts, API Analytics, and Control Plane hosting jurisdictions), and outlines how these are configured for the **AI CoE Dev Platform**.

---

## 1. Physical Runtime Hosting Regions
The physical region where the Apigee runtime plane infrastructure is deployed. Google manages these resources so that they are available redundantly in all zones within that region.

### **Europe Regions**
*   **Belgium** (`europe-west1`) — Low CO2, API Hub Supported
*   **London** (`europe-west2`) — Low CO2, API Hub Supported
*   **Frankfurt** (`europe-west3`) — API Hub Supported
*   **Netherlands** (`europe-west4`) — API Hub Supported
*   **Zurich** (`europe-west6`) — Low CO2, API Hub Supported
*   **Milan** (`europe-west8`) — API Hub Supported
*   **Paris** (`europe-west9`) — Low CO2, API Hub Supported
*   **Berlin** (`europe-west10`) — API Hub Supported
*   **Turin** (`europe-west12`) — API Hub Supported
*   **Warsaw** (`europe-central2`) — API Hub Supported
*   **Madrid** (`europe-southwest1`) — Low CO2, API Hub Supported
*   **Finland** (`europe-north1`) — Low CO2, API Hub Supported
*   **Stockholm** (`europe-north2`)

### **Americas Regions**
*   **Iowa** (`us-central1`), **Oregon** (`us-west1`), **Los Angeles** (`us-west2`), **Salt Lake City** (`us-west3`), **Las Vegas** (`us-west4`), **South Carolina** (`us-east1`), **Northern Virginia** (`us-east4`), **Columbus** (`us-east5`), **Dallas** (`us-south1`).
*   **Montréal** (`northamerica-northeast1`), **Toronto** (`northamerica-northeast2`).
*   **Santiago** (`southamerica-west1`), **São Paulo** (`southamerica-east1`).

### **Asia-Pacific, Middle East & Africa Regions**
*   **Sydney** (`australia-southeast1`), **Melbourne** (`australia-southeast2`), **Mumbai** (`asia-south1`), **Delhi** (`asia-south2`), **Singapore** (`asia-southeast1`), **Jakarta** (`asia-southeast2`), **Bangkok** (`asia-southeast3`), **Tokyo** (`asia-northeast1`), **Osaka** (`asia-northeast2`), **Seoul** (`asia-northeast3`), **Taiwan** (`asia-east1`), **Hong Kong** (`asia-east2`).
*   **Doha** (`me-central1`), **Dammam** (`me-central2`), **Tel Aviv** (`me-west1`), **Johannesburg** (`africa-south1`).

---

## 2. API Analytics Regions
The region where your Apigee API Analytics metadata is stored. Selected at the organization provisioning stage.

*   Available regions match the list of physical runtime regions. For EU residency compliance, options include:
    *   `europe-west1` (Belgium)
    *   `europe-west2` (London)
    *   `europe-west3` (Frankfurt)
    *   `europe-west4` (Netherlands)
    *   `europe-west6` (Zurich)
    *   `europe-west8` (Milan)
    *   `europe-west9` (Paris)
    *   `europe-west10` (Berlin)
    *   `europe-west12` (Turin)
    *   `europe-southwest1` (Madrid)
    *   `europe-central2` (Warsaw)
    *   `europe-north1` (Finland)

---

## 3. Control Plane Hosting Jurisdictions (Data Residency)
For strict data residency, Apigee supports regionalized control planes. The jurisdiction directly binds to the service endpoint.

| Control Plane Hosting Jurisdiction | Geopolitical Region / Supported Consumer Data Regions | Service Endpoint URL |
| :--- | :--- | :--- |
| **European Union (`eu`)** | Belgium (`europe-west1`), Frankfurt (`europe-west3`), Netherlands (`europe-west4`), Zurich (`europe-west6`), Milan (`europe-west8`), Paris (`europe-west9`), Turin (`europe-west12`), Warsaw (`europe-central2`), Madrid (`europe-southwest1`), Finland (`europe-north1`) | `apigee.eu.rep.googleapis.com` |
| **Germany (`de`)** | Multiple regions in Germany | `de-apigee.googleapis.com` |
| **France (`fr`)** | Single region: Paris (`europe-west9`) | `fr-apigee.googleapis.com` |
| **Switzerland (`ch`)** | Single region: Zurich (`europe-west6`) | `ch-apigee.googleapis.com` |
| **United States (`us`)** | Multiple regions in the United States | `apigee.us.rep.googleapis.com` |
| **Canada (`ca`)** | Multiple regions in Canada | `ca-apigee.googleapis.com` |
| **Australia (`au`)** | Multiple regions in Australia | `au-apigee.googleapis.com` |
| **India (`in`)** | Multiple regions in India | `apigee.in.rep.googleapis.com` |
| **Japan (`jp`)** | Multiple regions in Japan | `jp-apigee.googleapis.com` |
| **Qatar (`qa`)** | Single region: Doha (`me-central1`) | `qa-apigee.googleapis.com` |
| **Saudi Arabia (`sa`)** | Single region: Dammam (`me-central2`) | `sa-apigee.googleapis.com` |
| **Israel (`il`)** | Single region: Tel Aviv (`me-west1`) | `il-apigee.googleapis.com` |

---

## 4. Platform Architectural Choices (AI CoE Dev Environment)
Your deployment of the **AI CoE Dev Platform** implements the following specific locations to ensure strict data residency and compliance with organizational resource policies:

1.  **Physical Hosting Region (`region` = `"europe-west1"`):**
    *   Provisions the physical Apigee Instance compute resources in **Belgium (`europe-west1`)**.
    *   Enforces localized KMS encryption keys (`apigee/runtime-db` and `apigee/instance-disk`) in `europe-west1` matching the infrastructure's resource residency constraints.
    
2.  **API Analytics Storage Region (`analytics_region` = `"europe-west2"`):**
    *   Provisions the Apigee analytics database in **London (`europe-west2`)**.
    *   **API Hub Integration Support:** According to Google Cloud Apigee specifications, the **API Hub** feature is **not supported** when the analytics region is configured in `europe-west1` (Belgium). Setting it to `europe-west2` (London) fully enables API Hub capabilities.
    *   Separating the instance hosting region from the analytics region guarantees EU metadata boundary safety while distributing runtime and analytics overhead.

3.  **API Consumer Data Location (`api_consumer_data_location` = `"europe-west1"`):**
    *   Configures the regional Control Plane data residency directly inside **Belgium (`europe-west1`)**.
    *   This satisfies the GCP `gcp.resourceLocations` Organization Policy pinned to `europe-west1` and keeps all core control plane configs localized within your development boundary.
