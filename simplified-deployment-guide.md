# Simplified Deployment Guide for BAIC Global Website

This guide provides a simplified approach to deploying the BAIC Global website to Google Cloud Platform (GCP).

## Overview

The BAIC Global website consists of several components:

1. **Frontend** - A Nuxt.js application
2. **Admin Backend** - A Java Spring Boot application
3. **Web Backend** - A Java Spring Boot application
4. **GeoIP Service** - A Node.js microservice

## Deployment Process

### 1. Initialize Git Repository and Push to GitHub

```bash
# Initialize Git repository
./init-git-and-push.sh
```

This script will:
- Initialize a Git repository
- Add all files to the repository
- Create an initial commit
- Add a remote origin (you'll need to provide your GitHub repository URL)
- Push the code to GitHub

### 2. Deploy to Google Cloud Platform

#### Frontend Deployment

The frontend is deployed to App Engine using the `cloudbuild-frontend.yaml` configuration file.

```bash
gcloud builds submit --config=cloudbuild-frontend.yaml
```

#### Backend Deployment

The backend services are deployed to a Compute Engine VM using the `cloudbuild-vm-backend.yaml` configuration file.

```bash
gcloud builds submit --config=cloudbuild-vm-backend.yaml
```

## Key Fixes Implemented

### 1. Server-Side Rendering (SSR) Compatibility

We've fixed issues with browser-specific APIs being used in server-side rendering by making the following plugins client-side only:

- `vue-animate-number.js` - Fixed `requestAnimationFrame` error
- `vue-echarts.js` - Made client-side only
- `vue-lazyload.js` - Made client-side only
- `vue-tel-input.js` - Simplified and made client-side only
- `mq.js` - Made client-side only
- `swiper.js` - Updated to use `process.client` instead of `process.browser`

### 2. Backend Connectivity

We've updated the frontend and admin panel configurations to connect to the backend services running on the VM:

- Updated the proxy configuration in `nuxt.config.js` to point to the VM IP address
- Updated the API endpoint in `.env.production` for the admin panel to point to the VM IP address
- Updated the build scripts to ensure these changes are preserved during deployment

### 3. Java VM Deployment

We've improved the Java VM deployment process by:

- Adding better Java detection and configuration
- Setting the `JAVA_HOME` environment variable
- Using the full path to the Java executable in systemd service files
- Adding proper error handling for Java installation

## Deployment Architecture

```
                   ┌─────────────────┐
                   │                 │
                   │  Cloud Storage  │
                   │   (uploads)     │
                   │                 │
                   └────────┬────────┘
                            │
                            │
┌─────────────────┐  ┌─────▼────────┐  ┌─────────────────┐
│                 │  │              │  │                 │
│  App Engine     │  │  Compute     │  │  Cloud SQL      │
│  (Frontend)     │◄─┤  Engine VM   │◄─┤  (MySQL)        │
│                 │  │  (Backend)   │  │                 │
└─────────────────┘  └──────────────┘  └─────────────────┘
```

## Troubleshooting

### Frontend Issues

If you encounter errors with the frontend deployment, check:

1. The Cloud Build logs for any build errors
2. The App Engine logs for runtime errors
3. Make sure all plugins that use browser-specific APIs are configured to run only on the client side

### Backend Issues

If you encounter errors with the backend deployment, check:

1. The Cloud Build logs for any build errors
2. The VM logs for runtime errors
3. Make sure Java is properly installed and configured on the VM
4. Check the systemd service logs using `journalctl -u baic-admin` or `journalctl -u baic-web`

## Conclusion

This simplified approach allows for a more straightforward deployment process while maintaining the functionality of the BAIC Global website. By using GitHub for version control and Google Cloud Platform for hosting, we've created a robust and scalable deployment pipeline.
