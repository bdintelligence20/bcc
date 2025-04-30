# Quick Start Guide for BAIC Global Website Deployment

This guide provides a quick and straightforward approach to deploying the BAIC Global website to Google Cloud Platform (GCP).

## Prerequisites

- Google Cloud Platform account with billing enabled
- Google Cloud SDK installed and configured
- Git installed

## Deployment Steps

### 1. Initialize Git Repository and Push to GitHub

```bash
# Initialize Git repository and push to GitHub
./init-git-and-push.sh
```

### 2. Deploy Backend Services to VM

```bash
# Deploy backend services to VM
gcloud builds submit --config=cloudbuild-vm-backend.yaml
```

This will:
- Create a VM if it doesn't exist
- Build and deploy both backend services (admin and web) to the VM
- Configure the VM with the necessary environment

### 3. Deploy Frontend Website

```bash
# Deploy frontend website to App Engine
gcloud builds submit --config=cloudbuild-frontend.yaml
```

This will:
- Build the Nuxt.js application
- Configure it to connect to the backend services on the VM
- Deploy it to App Engine

### 4. Deploy Admin Panel

```bash
# Deploy admin panel to App Engine
gcloud builds submit --config=cloudbuild-admin.yaml
```

This will:
- Build the Vue.js admin panel
- Configure it to connect to the backend services on the VM
- Deploy it to App Engine

## Verification

After deployment, you can verify that everything is working correctly:

1. **Frontend Website**: Visit your App Engine URL (e.g., `https://baic-457613.appspot.com`)
2. **Admin Panel**: Visit your App Engine URL with the admin path (e.g., `https://baic-457613.appspot.com/manage-panel-path/`)
3. **Backend Services**: The backend services are running on the VM at `http://34.42.200.5:8080`

## Troubleshooting

If you encounter any issues:

1. **Check Cloud Build Logs**: 
   ```bash
   gcloud builds list
   gcloud builds log BUILD_ID
   ```

2. **Check App Engine Logs**:
   ```bash
   gcloud app logs tail
   ```

3. **Check VM Logs**:
   ```bash
   gcloud compute ssh baic-backend-vm --zone=us-central1-a
   sudo journalctl -u baic-admin
   sudo journalctl -u baic-web
   ```

## Configuration Files

The key configuration files that have been updated to connect to the VM:

1. **Frontend**: `beiqi-home-master/beiqi-home-master/nuxt.config.js`
   - Updated proxy configuration to point to VM IP

2. **Admin Panel**: `beiqi-web-master/beiqi-web-master/.env.production`
   - Updated API endpoint to point to VM IP

3. **Build Scripts**: `cloudbuild-frontend.yaml` and `cloudbuild-admin.yaml`
   - Updated to ensure configuration changes are preserved during deployment

## Next Steps

For more detailed information, refer to:
- `simplified-deployment-guide.md` - Comprehensive deployment guide
- `vm-deployment-guide.md` - Details on VM deployment
- `parallel-build-guide.md` - Guide for parallel builds
