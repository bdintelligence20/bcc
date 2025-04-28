# BAIC Global Parallel Build System

This guide explains how to use the new parallel build system for the BAIC Global codebase.

## Overview

The BAIC Global application has been split into four separate build configurations to enable parallel deployment:

1. **GeoIP Service** (Cloud Run)
2. **Frontend** (App Engine)
3. **Backend Services** (App Engine - ruoyi-admin and ruoyi-web)
4. **Admin Panel** (App Engine)

Each component has its own Cloud Build configuration file and trigger, allowing them to be built and deployed independently and concurrently.

## Benefits of Parallel Builds

- **Faster Deployments**: Components build in parallel, significantly reducing overall deployment time
- **Independent Updates**: You can update and deploy one component without rebuilding everything
- **Isolated Failures**: Issues with one component don't block the deployment of others
- **Better Resource Utilization**: Cloud Build resources are used more efficiently

## Cloud Build Configuration Files

The following Cloud Build configuration files have been created:

- `cloudbuild-geoip.yaml`: Builds and deploys the GeoIP service to Cloud Run
- `cloudbuild-frontend.yaml`: Builds and deploys the Frontend to App Engine
- `cloudbuild-backend.yaml`: Builds and deploys both Backend Admin and Backend Web to App Engine
- `cloudbuild-admin.yaml`: Builds and deploys the Admin Panel to App Engine

## Setting Up Cloud Build Triggers

To set up the Cloud Build triggers:

1. Go to the Cloud Build section in the GCP Console
2. Connect your GitHub repository
3. Create four separate triggers with the following settings:

### GeoIP Service Trigger
   - Name: `baic-geoip-trigger`
   - Event: `Push to a branch`
   - Source: `^master$`
   - Included files filter: `beiqi-geoip/**`
   - Configuration: `Cloud Build configuration file (yaml or json)`
   - Location: `Repository`
   - Cloud Build configuration file location: `cloudbuild-geoip.yaml`

### Frontend Trigger
   - Name: `baic-frontend-trigger`
   - Event: `Push to a branch`
   - Source: `^master$`
   - Included files filter: `beiqi-home-master/**`
   - Configuration: `Cloud Build configuration file (yaml or json)`
   - Location: `Repository`
   - Cloud Build configuration file location: `cloudbuild-frontend.yaml`

### Backend Trigger
   - Name: `baic-backend-trigger`
   - Event: `Push to a branch`
   - Source: `^master$`
   - Included files filter: `beiqi-service-master/**`
   - Configuration: `Cloud Build configuration file (yaml or json)`
   - Location: `Repository`
   - Cloud Build configuration file location: `cloudbuild-backend.yaml`

### Admin Panel Trigger
   - Name: `baic-admin-trigger`
   - Event: `Push to a branch`
   - Source: `^master$`
   - Included files filter: `beiqi-web-master/**`
   - Configuration: `Cloud Build configuration file (yaml or json)`
   - Location: `Repository`
   - Cloud Build configuration file location: `cloudbuild-admin.yaml`

## Using the Parallel Build System

### Automatic Builds

Once the triggers are set up, they will automatically run when changes are pushed to the corresponding directories in your GitHub repository:

- Changes to `beiqi-geoip/**` will trigger the GeoIP service build
- Changes to `beiqi-home-master/**` will trigger the Frontend build
- Changes to `beiqi-service-master/**` will trigger the Backend build
- Changes to `beiqi-web-master/**` will trigger the Admin Panel build

### Manual Builds

You can also manually trigger builds:

1. In the Cloud Build console, find the trigger you want to run
2. Click "Run trigger"
3. The selected component will be built and deployed

### Initial Deployment

For the initial deployment, you should run all four triggers to deploy all components:

1. Run the GeoIP service trigger
2. Run the Frontend trigger
3. Run the Backend trigger
4. Run the Admin Panel trigger

These can be run concurrently, as they are independent of each other.

## Shared Resources

All components share the following resources:

- **Cloud SQL Database**: All components connect to the same Cloud SQL instance
- **Cloud Storage Bucket**: All components use the same bucket for file uploads

Each Cloud Build configuration file includes steps to ensure these shared resources exist and are properly configured.

## Troubleshooting

If you encounter issues with the parallel build system:

1. Check the Cloud Build logs for the specific component that's failing
2. Verify that the Cloud Build trigger is correctly configured
3. Ensure that the Cloud Build configuration file is valid
4. Check that the component's app.yaml file is correctly configured

For more detailed troubleshooting information, refer to the main deployment guide.
