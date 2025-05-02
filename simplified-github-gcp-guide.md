# Simplified GitHub and GCP Deployment Guide for BAIC Global

This guide provides a straightforward approach to deploying the BAIC Global application to GitHub and Google Cloud Platform (GCP).

## Overview of Changes Made

1. **Fixed Database Connection Issues**:
   - Updated application-dev.yml files to use the correct database URL (34.69.17.6:3306) instead of localhost
   - Set default profile to "prod" in application.yml files
   - Updated vm-deploy.sh to use `--spring.config.location` instead of `--spring.config.additional-location`

2. **Frontend Configuration**:
   - Updated nuxt.config.js to dynamically get the backend VM IP address
   - Fixed API calls in the frontend code to use the correct prefixes

## Deployment Steps

### 1. Initialize GitHub Repository

```bash
# Clone the repository (if not already done)
git clone <repository-url>

# Initialize and push to GitHub
chmod +x init-git-and-push.sh
./init-git-and-push.sh
```

### 2. Deploy Backend Services to GCP VM

```bash
# Deploy backend services to VM
gcloud builds submit --config=cloudbuild-vm-backend.yaml
```

This will:
- Create a VM if it doesn't exist
- Deploy the JAR files to the VM
- Configure the services with the correct database connection
- Start the services

### 3. Deploy Frontend to GCP App Engine

```bash
# Update frontend configuration to point to the backend VM
chmod +x update-frontend-proxy.sh
./update-frontend-proxy.sh

# Deploy frontend to App Engine
gcloud builds submit --config=cloudbuild-frontend.yaml
```

### 4. Verify Deployment

```bash
# Check backend status
chmod +x check-backend-status.sh
./check-backend-status.sh
```

## Troubleshooting

### Backend Issues

If you encounter database connection issues:

1. Check the logs:
```bash
gcloud compute ssh cloudbuild@baic-backend-vm --zone=us-central1-a --command="sudo tail -n 100 /opt/baic/logs/admin.log"
gcloud compute ssh cloudbuild@baic-backend-vm --zone=us-central1-a --command="sudo tail -n 100 /opt/baic/logs/web.log"
```

2. Verify service configuration:
```bash
gcloud compute ssh cloudbuild@baic-backend-vm --zone=us-central1-a --command="sudo systemctl cat baic-admin"
gcloud compute ssh cloudbuild@baic-backend-vm --zone=us-central1-a --command="sudo systemctl cat baic-web"
```

3. Fix service configuration:
```bash
chmod +x fix-vm-services.sh
./fix-vm-services.sh
```

### Frontend Issues

If the frontend can't connect to the backend:

1. Check the nuxt.config.js file:
```bash
cat beiqi-home-master/beiqi-home-master/nuxt.config.js
```

2. Update the proxy configuration:
```bash
chmod +x update-nuxt-config.sh
./update-nuxt-config.sh
```

## Key Files

- **vm-deploy.sh**: Deploys the backend services to a VM
- **update-frontend-proxy.sh**: Updates the frontend configuration to point to the backend VM
- **fix-vm-services.sh**: Fixes service configuration issues on the VM
- **application-dev.yml**: Development configuration files (now updated with correct database URL)
- **application-prod.yml**: Production configuration files
- **application.yml**: Default configuration files (now set to use prod profile)

## Conclusion

This simplified approach to deploying the BAIC Global application to GitHub and GCP provides a straightforward and maintainable solution. By using GitHub for version control, a GCP VM for the backend services, and GCP App Engine for the frontend, you can achieve a reliable and scalable deployment.
