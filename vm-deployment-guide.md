# BAIC Global VM Deployment Guide

This guide provides instructions for deploying the BAIC Global Java backend services to a Compute Engine VM using Cloud Build.

## Overview

The BAIC Global Java backend services (ruoyi-admin and ruoyi-web) are now deployed to a Compute Engine VM instead of App Engine or Cloud Run. This approach follows the best practice mentioned in the project documentation, which is to run the JAR files directly on a server.

## How It Works

1. Cloud Build compiles the Java projects using Maven
2. The resulting JAR files are uploaded to a Compute Engine VM
3. The JAR files are run as systemd services on the VM
4. The services are accessible via the VM's external IP address

## Deployment Process

The deployment process is fully automated using Cloud Build. Here's what happens:

1. The `cloudbuild-vm-backend.yaml` file defines the build and deployment steps
2. The `vm-deploy.sh` script handles the VM creation and configuration
3. The JAR files are built and uploaded to the VM
4. The services are started or restarted on the VM

## Manual Deployment

To manually trigger a deployment:

1. Go to the Cloud Build section in the GCP Console
2. Find the `baic-backend-vm-trigger` trigger
3. Click "Run trigger"
4. Wait for the build to complete

## Accessing the Services

After deployment, the services are accessible at:

- Admin Backend: `http://VM_EXTERNAL_IP:8080`
- Web Backend: `http://VM_EXTERNAL_IP:8080`

You can find the VM's external IP address in the Cloud Build logs or by running:

```bash
gcloud compute instances describe baic-backend-vm --zone=us-central1-a --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
```

## Troubleshooting

If you encounter issues with the deployment:

1. Check the Cloud Build logs for build errors
2. Check the VM logs for runtime errors:
   ```bash
   gcloud compute ssh baic-backend-vm --zone=us-central1-a --command="sudo cat /opt/baic/logs/admin.log"
   gcloud compute ssh baic-backend-vm --zone=us-central1-a --command="sudo cat /opt/baic/logs/web.log"
   ```
3. Check the service status:
   ```bash
   gcloud compute ssh baic-backend-vm --zone=us-central1-a --command="sudo systemctl status baic-admin"
   gcloud compute ssh baic-backend-vm --zone=us-central1-a --command="sudo systemctl status baic-web"
   ```

## VM Configuration

The VM is configured with:

- Machine type: e2-standard-2 (2 vCPUs, 8 GB memory)
- Boot disk: 20 GB
- OS: Debian 11
- Java: OpenJDK 8
- Firewall rules: Allow HTTP (80), HTTPS (443), and custom port 8080

## Service Configuration

The Java services are configured as systemd services:

- Service names: `baic-admin` and `baic-web`
- Working directory: `/opt/baic`
- JAR files: `/opt/baic/ruoyi-admin.jar` and `/opt/baic/ruoyi-web.jar`
- Log files: `/opt/baic/logs/admin.log` and `/opt/baic/logs/web.log`
- JVM options: `-Xms1024m -Xmx2048m`
- Profile: `prod`

## Benefits of VM Deployment

- **Simplicity**: Runs the JAR files directly, as intended by the project design
- **Reliability**: No containerization complexity or startup issues
- **Performance**: Dedicated resources for the Java applications
- **Flexibility**: Easy to customize and troubleshoot
- **Cost-effective**: Single VM for both services

## Next Steps

For production use, consider:

1. Setting up a load balancer in front of the VM
2. Configuring SSL/TLS for secure connections
3. Setting up a domain name for the services
4. Implementing VM instance groups for high availability
5. Setting up monitoring and alerting for the VM and services
