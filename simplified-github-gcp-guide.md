# Simplified GitHub and GCP Deployment Guide for BAIC Global

This guide provides a straightforward approach to deploying the BAIC Global application to GitHub and Google Cloud Platform (GCP).

## Overview of Changes Made

1. **Consolidated Architecture**:
   - All components (backend services, database, frontend, admin panel) deployed to a single VM
   - Simplified networking and configuration
   - Eliminated cross-service communication issues

2. **Database Configuration**:
   - Local MariaDB database on the VM
   - Updated application-dev.yml and application-prod.yml files to use the local database (127.0.0.1:3306/baicintl)

3. **Frontend and Admin Panel**:
   - Deployed to the VM instead of App Engine
   - Frontend running with PM2 process manager
   - Admin panel served as static files by Nginx
   - Nginx configured to route requests appropriately

4. **Backend Services**:
   - Running as systemd services on the VM
   - Connected to the local database
   - Configured with proper paths for uploads

## Deployment Steps

### 1. Initialize GitHub Repository

```bash
# Clone the repository (if not already done)
git clone <repository-url>

# Initialize and push to GitHub
chmod +x init-git-and-push.sh
./init-git-and-push.sh
```

### 2. Deploy Backend Services to VM

```bash
# Deploy backend services to VM
gcloud builds submit --config=cloudbuild-vm-backend.yaml
```

This will:
- Create a VM if it doesn't exist
- Install all necessary dependencies (Nginx, Node.js, MariaDB, etc.)
- Configure the database
- Set up directories and permissions
- Build the backend services
- Deploy the JAR files to the VM
- Configure the services with the correct database connection
- Start the services

### 3. Deploy Frontend to VM

```bash
# Deploy frontend to VM
gcloud builds submit --config=cloudbuild-frontend.yaml
```

This will:
- Build the frontend application
- Deploy it to the VM
- Configure Nginx to serve it
- Start the application with PM2

### 4. Deploy Admin Panel to VM

```bash
# Deploy admin panel to VM
gcloud builds submit --config=cloudbuild-admin.yaml
```

This will:
- Build the admin panel
- Deploy it to the VM
- Configure Nginx to serve it

### 5. Verify Deployment

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

If the frontend isn't working properly:

1. Check the Nginx configuration:
```bash
gcloud compute ssh cloudbuild@baic-backend-vm --zone=us-central1-a --command="sudo cat /etc/nginx/sites-available/frontend"
```

2. Check the PM2 status:
```bash
gcloud compute ssh cloudbuild@baic-backend-vm --zone=us-central1-a --command="sudo pm2 status"
```

3. Check the frontend logs:
```bash
gcloud compute ssh cloudbuild@baic-backend-vm --zone=us-central1-a --command="sudo pm2 logs frontend"
```

### Admin Panel Issues

If the admin panel isn't working properly:

1. Check the Nginx configuration:
```bash
gcloud compute ssh cloudbuild@baic-backend-vm --zone=us-central1-a --command="sudo cat /etc/nginx/sites-available/admin"
```

2. Check the Nginx error logs:
```bash
gcloud compute ssh cloudbuild@baic-backend-vm --zone=us-central1-a --command="sudo tail -n 100 /var/log/nginx/error.log"
```

## Key Files

- **cloudbuild-vm-backend.yaml**: Builds and deploys the backend services to the VM, including VM setup
- **cloudbuild-frontend.yaml**: Builds and deploys the frontend to the VM
- **cloudbuild-admin.yaml**: Builds and deploys the admin panel to the VM
- **application-dev.yml**: Development configuration files
- **application-prod.yml**: Production configuration files

## Conclusion

This simplified approach to deploying the BAIC Global application to GitHub and GCP provides a straightforward and maintainable solution. By consolidating all components on a single VM, we eliminate network connectivity issues, simplify the architecture, and reduce the number of moving parts that could potentially fail. This approach is more cost-effective, easier to maintain, and provides better performance due to reduced latency between components.
