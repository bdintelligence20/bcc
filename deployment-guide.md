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
   - The build is configured to use Cloud Logging only (no storage bucket for logs)
   - You can view logs in the Cloud Build console or using the GCP Logging interface
2. Check the App Engine logs for runtime errors
3. Verify that all necessary APIs are enabled
4. Ensure that the Cloud SQL instance is properly configured
5. Check that the app.yaml files have the correct configuration

### Common Issues

- **Service Account Error**: If you see an error about service accounts and logs bucket, make sure you're using the latest version of cloudbuild.yaml which includes the `options: { logging: CLOUD_LOGGING_ONLY }` configuration.

- **GeoIP Service Port Error**: The GeoIP service needs to listen on the port specified by the PORT environment variable (typically 8080) in Cloud Run. The cloudbuild.yaml file has been updated to automatically modify the app.js file to use `const port = process.env.PORT || 3000;` instead of the hardcoded port 3000. If you're still seeing port-related errors, make sure the GeoIP service is properly configured to listen on the PORT environment variable.

- **Node.js Runtime Version**: The app.yaml files for Node.js services have been updated to use Node.js 20 (the latest supported version) instead of Node.js 14 (which is deprecated). If you see errors about deprecated runtimes, make sure you're using the latest versions of the app.yaml files.

- **NPM Command Not Found**: The cloudbuild.yaml file has been updated to use the Node.js Docker image for steps that require npm. If you see errors about npm not being found, make sure you're using the latest version of the cloudbuild.yaml file.

- **Missing SCSS Files**: The beiqi-home-master service requires an index.scss file in the assets/scss directory. This file has been created and added to the repository. The cloudbuild.yaml file has also been updated to create this file during the build process if it doesn't exist. If you see errors about missing SCSS files, make sure you're using the latest version of the cloudbuild.yaml file.

- **SCSS Variable Resolution**: The Nuxt configuration has been updated to properly load SCSS variables globally using the `@nuxtjs/style-resources` module. This ensures that variables defined in variables.scss are available to all components without needing to import them explicitly.

- **Missing Dependencies**: The package.json file has been updated to include `@nuxtjs/composition-api`, which is required by the nav.js plugin. The cloudbuild.yaml file has also been updated to install this dependency during the build process.

- **Asset Resolution**: The Nuxt configuration has been updated to properly resolve asset files, particularly webp images. This ensures that images referenced in components are correctly resolved during the build process.

- **i18n Block Handling**: The Nuxt configuration has been updated to properly handle i18n blocks in Vue components. This is done by adding the `@intlify/vue-i18n-loader` dependency and configuring it in the build process. This ensures that internationalization blocks in Vue components are correctly processed during the build.

- **Case Sensitivity in File Paths**: Some image file references in Vue components had case sensitivity issues. For example, referencing 'new-x7-01.webp' when the actual file name is 'new-X7-01.webp' (with capital X). These references have been updated to match the actual file names. This is particularly important when deploying to Linux-based environments like GCP, which are case-sensitive for file paths.

- **Port Configuration for Other Services**: All services have been configured to use the correct ports:
  - **beiqi-geoip**: Updated to use PORT environment variable (8080 in Cloud Run)
  - **beiqi-home-master**: Already configured to use port 8080 in nuxt.config.js
  - **beiqi-service-master/ruoyi-admin**: Already configured to use port 8080 in application-prod.yml
  - **beiqi-service-master/ruoyi-web**: Already configured to use port 8080 in application-prod.yml
  - **beiqi-web-master**: Serves static files through App Engine, so port configuration is not applicable

## Additional Resources

- [GCP Cloud Build Documentation](https://cloud.google.com/build/docs)
- [GCP App Engine Documentation](https://cloud.google.com/appengine/docs)
- [GCP Cloud Run Documentation](https://cloud.google.com/run/docs)
- [GCP Cloud SQL Documentation](https://cloud.google.com/sql/docs)
