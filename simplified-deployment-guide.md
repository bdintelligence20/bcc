# Simplified Deployment Guide for BAIC Global

This guide provides a simplified approach to deploying the BAIC Global website and admin panel on Google Cloud Platform.

## What's Been Fixed

1. **Database Connection Issue**: The backend services were failing to connect to the MySQL database due to incorrect configuration. The error logs showed they were trying to connect to "localhost:3,306" (with a comma in the port number).

2. **Mixed Content Issues**: The admin panel was being served over HTTPS from App Engine, but it was trying to make API requests to an HTTP endpoint, which modern browsers block for security reasons.

3. **Frontend Configuration**: The frontend configuration has been updated to use relative URLs for API requests, which will work regardless of the protocol (HTTP or HTTPS).

## Deployment Steps - Just Push to GitHub!

All the fixes have been integrated into the Cloud Build configuration files. Now you can simply:

1. Initialize a Git repository and push to GitHub:
   ```bash
   ./init-git-and-push.sh
   ```
   or on Windows:
   ```bash
   init-git-and-push.bat
   ```

2. Set up Cloud Build triggers in the Google Cloud Console to automatically deploy when changes are pushed to GitHub:
   - Create a trigger for the backend services using `cloudbuild-vm-backend.yaml`
   - Create a trigger for the frontend using `cloudbuild-frontend.yaml`
   - Create a trigger for the admin panel using `cloudbuild-admin.yaml`

That's it! When you push changes to GitHub, Cloud Build will automatically:
1. Deploy the backend services to the VM with the correct database configuration
2. Deploy the frontend to App Engine
3. Deploy the admin panel to App Engine

## What Changed

### Backend Configuration

1. Updated the VM deployment script (`vm-deploy.sh`) to automatically:
   - Create external configuration files with the correct database connection URL (34.69.17.6:3306)
   - Update the systemd service files to use these external configuration files
   - Restart the services with the new configuration

### Admin Panel Configuration

1. Updated the admin panel to use relative URLs for API requests ('/api' instead of 'http://34.42.200.5:8080/api')
2. Added missing configuration for file uploads and other settings

### Frontend Configuration

1. Updated the frontend proxy configuration to use relative URLs for API requests
2. Added proper path rewriting to ensure requests are forwarded correctly
3. Added a proxy for file uploads

## Accessing the Application

After deployment, the application will be available at:

- Frontend: `https://baic-457613.appspot.com/`
- Admin Panel: `https://admin-panel-dot-baic-457613.uc.r.appspot.com/manage-panel-path/`
- Backend API: `http://34.42.200.5:8080/api/`
- Backend Home API: `http://34.42.200.5:8080/home-api/`

## Troubleshooting

If you encounter any issues:

1. Check the Cloud Build logs in the Google Cloud Console

2. Check the backend service logs on the VM:
   ```bash
   gcloud compute ssh baic-backend-vm --zone=us-central1-a
   sudo journalctl -u baic-admin.service -f
   sudo journalctl -u baic-web.service -f
   ```

3. Check the application logs on the VM:
   ```bash
   gcloud compute ssh baic-backend-vm --zone=us-central1-a
   sudo tail -f /opt/baic/logs/admin.log
   sudo tail -f /opt/baic/logs/web.log
   ```

4. Check the App Engine logs in the Google Cloud Console
