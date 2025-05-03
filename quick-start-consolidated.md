# BAIC Global Consolidated Deployment Quick Start Guide

This guide provides a quick overview of deploying the BAIC Global application with all components (backend, database, frontend, admin panel) on a single VM.

## Prerequisites

- Google Cloud Platform account with billing enabled
- Google Cloud SDK installed and configured
- Git installed

## Deployment Steps

### 1. Clone the Repository

```bash
git clone <repository-url>
cd <repository-directory>
```

### 2. Deploy Backend Services

```bash
# Deploy backend services to VM
gcloud builds submit --config=cloudbuild-vm-backend.yaml
```

### 3. Deploy Frontend

```bash
# Deploy frontend to VM
gcloud builds submit --config=cloudbuild-frontend.yaml
```

### 4. Deploy Admin Panel

```bash
# Deploy admin panel to VM
gcloud builds submit --config=cloudbuild-admin.yaml
```

### 5. Access the Application

Once all components are deployed, you can access:

- Frontend: http://<VM-IP-ADDRESS>
- Admin Panel: http://<VM-IP-ADDRESS>/admin

To get the VM's IP address:

```bash
gcloud compute instances describe baic-backend-vm --zone=us-central1-a --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
```

## Troubleshooting

If you encounter issues:

1. Check the backend logs:
```bash
gcloud compute ssh cloudbuild@baic-backend-vm --zone=us-central1-a --command="sudo tail -n 100 /opt/baic/logs/admin.log"
gcloud compute ssh cloudbuild@baic-backend-vm --zone=us-central1-a --command="sudo tail -n 100 /opt/baic/logs/web.log"
```

2. Check the Nginx logs:
```bash
gcloud compute ssh cloudbuild@baic-backend-vm --zone=us-central1-a --command="sudo tail -n 100 /var/log/nginx/error.log"
```

3. Check the PM2 status for the frontend:
```bash
gcloud compute ssh cloudbuild@baic-backend-vm --zone=us-central1-a --command="sudo pm2 status"
```

## Architecture Overview

- **Backend Services**: Java Spring Boot applications running as systemd services
- **Database**: MariaDB running locally on the VM
- **Frontend**: Nuxt.js application running with PM2
- **Admin Panel**: Vue.js application served as static files by Nginx
- **Nginx**: Central proxy routing requests to the appropriate service

All components are on the same VM, eliminating network latency and simplifying the architecture.
