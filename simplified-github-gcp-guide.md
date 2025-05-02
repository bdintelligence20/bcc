# Simplified GitHub and GCP Deployment Guide for BAIC Global

This guide provides a straightforward approach to deploying the BAIC Global application using GitHub and Google Cloud Platform (GCP).

## Overview

The deployment process consists of the following steps:

1. Initialize a GitHub repository and push the code
2. Deploy the backend services to a GCP VM
3. Deploy the frontend to GCP App Engine
4. Connect the frontend to the backend

## Prerequisites

- GitHub account
- GCP account with billing enabled
- gcloud CLI installed and configured
- Git installed

## Step 1: Initialize GitHub Repository and Push Code

1. Create a new GitHub repository
2. Initialize the local repository and push the code:

```bash
# Run the initialization script
chmod +x init-git-and-push.sh
./init-git-and-push.sh
```

## Step 2: Deploy Backend Services to GCP VM

1. Create a VM instance:

```bash
gcloud compute instances create baic-backend-vm \
  --zone=us-central1-a \
  --machine-type=e2-medium \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --boot-disk-size=20GB \
  --tags=http-server,https-server
```

2. Allow HTTP and HTTPS traffic:

```bash
gcloud compute firewall-rules create allow-http \
  --allow tcp:80,tcp:8080 \
  --target-tags=http-server

gcloud compute firewall-rules create allow-https \
  --allow tcp:443 \
  --target-tags=https-server
```

3. Deploy the backend services to the VM:

```bash
# Run the VM deployment script
chmod +x vm-deploy.sh
./vm-deploy.sh
```

## Step 3: Deploy Frontend to GCP App Engine

1. Deploy the frontend using Cloud Build:

```bash
gcloud builds submit --config=cloudbuild-frontend.yaml
```

## Step 4: Connect Frontend to Backend

The frontend is already configured to connect to the backend services running on the VM. The configuration is in the following files:

- `beiqi-home-master/beiqi-home-master/nuxt.config.js`: Contains the proxy configuration
- `beiqi-home-master/beiqi-home-master/plugins/axios.js`: Handles API request routing
- `beiqi-home-master/beiqi-home-master/api/apiList/*.js`: Contains the API endpoint definitions

## Troubleshooting

### Backend Issues

If you encounter issues with the backend services, you can use the following scripts to diagnose and fix them:

```bash
# Check backend status
chmod +x check-backend-status.sh
./check-backend-status.sh

# Fix backend VM configuration
chmod +x fix-backend-vm.sh
./fix-backend-vm.sh
```

### Frontend Issues

If you encounter issues with the frontend, you can use the following script to fix API calls:

```bash
# Fix frontend API calls
chmod +x fix-api-calls.sh
./fix-api-calls.sh
```

## Conclusion

This simplified approach to deploying the BAIC Global application to GitHub and GCP provides a straightforward and maintainable solution. By using GitHub for version control, a GCP VM for the backend services, and GCP App Engine for the frontend, you can achieve a reliable and scalable deployment.
