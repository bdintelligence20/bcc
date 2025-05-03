# Docker Deployment Guide for BAIC Global

This guide explains how to deploy the BAIC Global application using Docker and Cloud Build.

## Overview

This deployment approach uses Docker containers to solve the database connection issue and provide a more reliable deployment process. The key advantages are:

1. **Isolation**: Each service runs in its own container
2. **Environment Variables**: Database connection details are passed as environment variables
3. **No Port Issues**: The comma in the port number is no longer a problem
4. **Easy Updates**: Just rebuild the containers when you make changes

## Prerequisites

1. A Google Cloud Platform (GCP) project with the following APIs enabled:
   - Cloud Build API
   - Container Registry API
   - Compute Engine API

2. A GitHub repository containing the BAIC Global codebase

## Files Created

1. **Dockerfile.admin**: Dockerfile for the admin service
2. **Dockerfile.web**: Dockerfile for the web service
3. **cloudbuild-docker.yaml**: Cloud Build configuration file

## Deployment Steps

### 1. Push the Code to GitHub

Use the provided `init-git-and-push.sh` script to initialize a Git repository and push the code to GitHub:

```bash
chmod +x init-git-and-push.sh
./init-git-and-push.sh
```

### 2. Set Up a Cloud Build Trigger

1. Go to the GCP Console
2. Navigate to Cloud Build > Triggers
3. Click "Create Trigger"
4. Connect to your GitHub repository
5. Configure the trigger:
   - Name: `baic-docker-deploy`
   - Event: `Push to a branch`
   - Source: `^main$` (or your branch name)
   - Configuration: `Cloud Build configuration file (yaml or json)`
   - Location: `Repository`
   - Cloud Build configuration file location: `cloudbuild-docker.yaml`
6. Click "Create"

### 3. Run the Trigger

1. Click on the trigger you just created
2. Click "Run Trigger"
3. Select the branch to build (e.g., `main`)
4. Click "Run"

### 4. Monitor the Build

1. Go to Cloud Build > History
2. Click on the running build to view its progress
3. Check the logs for any errors

### 5. Verify the Deployment

After the build completes successfully, you can verify the deployment:

1. SSH into the VM:
   ```bash
   gcloud compute ssh baic-backend-vm --zone=us-central1-a
   ```

2. Check if the Docker containers are running:
   ```bash
   sudo docker ps
   ```

3. Check the container logs:
   ```bash
   sudo docker logs $(sudo docker ps -q --filter 'name=admin-service')
   sudo docker logs $(sudo docker ps -q --filter 'name=web-service')
   ```

4. Access the services:
   - Admin Backend: `http://<VM-IP>:8080/api`
   - Web Backend: `http://<VM-IP>:8080/home-api`

## Troubleshooting

### Container Not Starting

If a container is not starting, check the logs:

```bash
sudo docker logs $(sudo docker ps -a -q --filter 'name=admin-service')
sudo docker logs $(sudo docker ps -a -q --filter 'name=web-service')
```

### Database Connection Issues

If there are database connection issues, check the MySQL server:

```bash
sudo systemctl status mariadb
sudo mysql -u ruoyi -p -e "SHOW DATABASES;"
```

### Restoring from Backup

If you need to restore from the backup:

```bash
sudo cp -r ~/baic-backup/* /opt/baic/
```

## Maintenance

### Updating the Services

To update the services, simply push changes to your GitHub repository and the Cloud Build trigger will automatically rebuild and redeploy the containers.

### Stopping the Services

To stop the services:

```bash
cd ~
sudo docker-compose down
```

### Restarting the Services

To restart the services:

```bash
cd ~
sudo docker-compose up -d
```

## Conclusion

This Docker-based deployment approach provides a more reliable and maintainable way to deploy the BAIC Global application. It solves the database connection issue by using environment variables and container networking, and it makes updates easier by automating the build and deployment process.
