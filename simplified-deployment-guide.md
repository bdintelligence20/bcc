# Simplified Deployment Guide for BAIC Global

This guide provides a straightforward approach to deploying the BAIC Global application to GitHub and Google Cloud Platform (GCP).

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

1. Deploy the backend services to a VM using Cloud Build:

```bash
# Run the VM deployment script
gcloud builds submit --config=cloudbuild-vm-backend.yaml
```

This will:
- Create a VM if it doesn't exist
- Deploy the JAR files to the VM
- Configure the services to run on startup
- Set up the database connection

## Step 3: Deploy Frontend to GCP App Engine

1. Deploy the frontend using Cloud Build:

```bash
gcloud builds submit --config=cloudbuild-frontend.yaml
```

## Step 4: Verify and Fix Issues

If you encounter any issues with the backend services, you can use the following scripts to diagnose and fix them:

```bash
# Check backend status
chmod +x check-backend-status.sh
./check-backend-status.sh

# Fix backend VM services
chmod +x fix-vm-services.sh
./fix-vm-services.sh
```

## Key Changes Made

1. **Fixed Database Connection**: Updated the service files to use `--spring.config.location` instead of `--spring.config.additional-location` to ensure that the external configuration files are properly loaded and take precedence over any embedded configuration.

2. **Simplified Deployment Process**: Created scripts to automate the deployment process and fix any issues that might arise.

3. **Direct Database Connection**: Updated the database connection URLs to use a direct connection to the database instead of the Cloud SQL socket factory.

## Troubleshooting

### Backend Issues

If you encounter issues with the backend services, you can use the following scripts to diagnose and fix them:

```bash
# Check backend status
chmod +x check-backend-status.sh
./check-backend-status.sh

# Fix backend VM services
chmod +x fix-vm-services.sh
./fix-vm-services.sh
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
