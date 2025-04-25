# BAIC Global Quick Start Guide

This guide provides a quick overview of how to deploy the BAIC Global codebase to GitHub and Google Cloud Platform (GCP).

## Step 1: Push to GitHub

### Using the provided scripts:

**For Linux/Mac:**
```bash
chmod +x init-git-and-push.sh
./init-git-and-push.sh <github-username> <repository-name>
```

**For Windows:**
```
init-git-and-push.bat <github-username> <repository-name>
```

### Manually:
```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/<github-username>/<repository-name>.git
git push -u origin master
```

## Step 2: Set Up GCP

1. Create a new GCP project or use an existing one
2. Enable required APIs:
   - Cloud Build API
   - App Engine Admin API
   - Cloud Run Admin API
   - Cloud Storage API
   - Cloud SQL Admin API

## Step 3: Use Existing Cloud SQL Instance and File Uploads

### Database Configuration
The project is already configured to use an existing Cloud SQL instance:

- **Connection name**: `baic-457613:us-central1:baic-mysql`
- **Public IP address**: `34.69.17.6`
- **Port**: `3306`

No additional setup is required for the database.

### File Uploads
The project uses a Cloud Storage bucket for file uploads:

- The `uploadPath` directory at the root of the project contains all uploaded files
- These files will be automatically copied to a Cloud Storage bucket during deployment
- The application will be configured to use this bucket for file storage in production

### Runtime Versions and Build Process
The project has been updated to use the latest supported runtime versions and build process:

- Node.js services now use Node.js 20 instead of Node.js 14 (which is deprecated)
- The build process has been updated to use the appropriate Docker images for each step
- Missing SCSS files are automatically created during the build process

## Step 4: Set Up Cloud Build Trigger

1. Go to Cloud Build in GCP Console
2. Connect your GitHub repository
3. Create a build trigger:
   - Name: `baic-global-trigger`
   - Event: `Push to a branch`
   - Source: `^master$`
   - Configuration: `Cloud Build configuration file`
   - Location: `Repository`
   - File location: `cloudbuild.yaml`

## Step 5: Trigger the Build

1. In the Cloud Build console, find your trigger
2. Click "Run trigger"

## Step 6: Access Your Application

After the build completes, access your applications at:

- Frontend: `https://frontend-dot-YOUR_PROJECT_ID.appspot.com/`
- Admin Panel: `https://admin-panel-dot-YOUR_PROJECT_ID.appspot.com/`
- Backend Admin: `https://YOUR_PROJECT_ID.appspot.com/`
- Backend Web: `https://web-backend-dot-YOUR_PROJECT_ID.appspot.com/`
- GeoIP Service: `https://beiqi-geoip-RANDOM_HASH-uc.a.run.app/`

For more detailed instructions, see the [Deployment Guide](deployment-guide.md).
