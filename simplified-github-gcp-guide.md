# Simplified GitHub and GCP Deployment Guide

This guide provides a streamlined approach to deploying the BAIC Global application to GitHub and Google Cloud Platform (GCP).

## Overview

The deployment process has been simplified to address the database connection issue and streamline the deployment process:

1. Initialize a GitHub repository and push the code
2. Deploy to GCP using Cloud Build with the fixed deployment script

## Step 1: Initialize GitHub Repository

```bash
# Initialize Git repository
git init

# Add all files to Git
git add .

# Commit the changes
git commit -m "Initial commit"

# Add GitHub remote (replace with your GitHub repository URL)
git remote add origin https://github.com/your-username/baic-global.git

# Push to GitHub
git push -u origin main
```

## Step 2: Deploy to GCP

1. Create a new Cloud Build trigger in the GCP Console:
   - Go to Cloud Build > Triggers
   - Click "Create Trigger"
   - Connect to your GitHub repository
   - Set the trigger to use the `cloudbuild-vm-backend.yaml` configuration file

2. Run the Cloud Build trigger:
   - Click "Run Trigger" to start the deployment process
   - The deployment will:
     - Create a VM if it doesn't exist
     - Set up the necessary environment
     - Build the Java applications
     - Deploy the applications to the VM
     - Configure the database connection properly

## What's Fixed

The deployment process has been improved to fix the database connection issue:

1. Added `spring.main.allow-bean-definition-overriding=true` to the configuration files
2. Created an additional `application.properties` file to override any settings in the JAR files
3. Updated the systemd service files to use the correct configuration files
4. Created a symbolic link for the database socket
5. Ensured the MySQL server is running before starting the applications

## Verification

After deployment, you can verify the application is working correctly by:

1. Accessing the admin backend at: `http://<VM-IP>:8080/api`
2. Accessing the web backend at: `http://<VM-IP>:8080/home-api`

## Troubleshooting

If you encounter any issues, you can:

1. Check the logs:
   ```bash
   sudo tail -n 50 /opt/baic/logs/admin.log
   sudo tail -n 50 /opt/baic/logs/web.log
   ```

2. Restart the services:
   ```bash
   sudo systemctl restart baic-admin
   sudo systemctl restart baic-web
   ```

3. Check the database connection:
   ```bash
   sudo mysql -u ruoyi -p -e "SHOW DATABASES;"
   ```

## Next Steps

Once the backend services are running correctly, you can:

1. Deploy the frontend applications
2. Configure a load balancer
3. Set up DNS entries
4. Configure HTTPS
