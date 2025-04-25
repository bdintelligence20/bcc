# BAIC Global Deployment Guide

This guide provides step-by-step instructions for deploying the BAIC Global codebase to GitHub and Google Cloud Platform (GCP).

## Overview

The deployment process involves:
1. Pushing the code to GitHub
2. Setting up GCP resources
3. Configuring Cloud Build to automatically deploy the application

## Prerequisites

- Git installed on your local machine
- A GitHub account
- A Google Cloud Platform account
- Google Cloud SDK installed (optional, but helpful for local testing)

## Step 1: Initialize Git and Push to GitHub

```bash
# Initialize Git in the current directory (if not already done)
git init

# Add all files (excluding build artifacts)
git add .
git commit -m "Initial commit"

# Create a new repository on GitHub
# Then add the remote and push
git remote add origin https://github.com/yourusername/baic-global.git
git push -u origin master
```

## Step 2: Set Up GCP Project

1. Create a new GCP project or use an existing one
2. Enable the following APIs:
   - Cloud Build API
   - App Engine Admin API
   - Cloud Run Admin API
   - Cloud Storage API
   - Cloud SQL Admin API

## Step 3: Use Existing Cloud SQL Instance and File Uploads

### Database Configuration

The project is already configured to use an existing Cloud SQL instance with the following details:

- **Connection name**: `baic-457613:us-central1:baic-mysql`
- **Public IP address**: `34.69.17.6`
- **Port**: `3306`

The cloudbuild.yaml file has been configured to automatically update the database connection details in the application configuration files during the build process.

If you need to connect to the database directly, you can use the following command:

```bash
gcloud sql connect baic-mysql --user=ruoyi
```

Or connect using a MySQL client:

```bash
mysql -h 34.69.17.6 -u ruoyi -p
```

### File Uploads

The project has been configured to use a Cloud Storage bucket for file uploads. The `uploadPath` directory at the root of the project contains all the uploaded files, which will be copied to a Cloud Storage bucket during deployment.

The cloudbuild.yaml file has been configured to:
1. Create a Cloud Storage bucket named `baic-uploads` if it doesn't exist
2. Copy all files from the `uploadPath` directory to the bucket
3. Update the application configuration to use the bucket for file storage in production

## Step 4: Set Up Cloud Build Trigger

1. Go to the Cloud Build section in the GCP Console
2. Connect your GitHub repository
3. Create a new trigger with the following settings:
   - Name: `baic-global-trigger`
   - Event: `Push to a branch`
   - Source: `^master$`
   - Configuration: `Cloud Build configuration file (yaml or json)`
   - Location: `Repository`
   - Cloud Build configuration file location: `cloudbuild.yaml`

## Step 5: Trigger the First Build

1. In the Cloud Build console, find your trigger
2. Click "Run trigger"
3. This will:
   - Build and deploy the GeoIP service to Cloud Run
   - Deploy the Frontend to App Engine
   - Deploy the Backend Admin to App Engine
   - Deploy the Backend Web to App Engine
   - Deploy the Admin Panel to App Engine

## Step 6: Verify Deployment

After the build completes, you can access your applications at:

- Frontend: `https://frontend-dot-YOUR_PROJECT_ID.appspot.com/`
- Admin Panel: `https://admin-panel-dot-YOUR_PROJECT_ID.appspot.com/`
- Backend Admin: `https://YOUR_PROJECT_ID.appspot.com/`
- Backend Web: `https://web-backend-dot-YOUR_PROJECT_ID.appspot.com/`
- GeoIP Service: `https://beiqi-geoip-RANDOM_HASH-uc.a.run.app/`

Replace `YOUR_PROJECT_ID` with your actual GCP project ID.

## Troubleshooting

If you encounter any issues during deployment:

1. Check the Cloud Build logs for build errors
2. Check the App Engine logs for runtime errors
3. Verify that all necessary APIs are enabled
4. Ensure that the Cloud SQL instance is properly configured
5. Check that the app.yaml files have the correct configuration

## Additional Resources

- [GCP Cloud Build Documentation](https://cloud.google.com/build/docs)
- [GCP App Engine Documentation](https://cloud.google.com/appengine/docs)
- [GCP Cloud Run Documentation](https://cloud.google.com/run/docs)
- [GCP Cloud SQL Documentation](https://cloud.google.com/sql/docs)
