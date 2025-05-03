# Frontend Fix Guide for BAIC Global

This guide provides instructions for fixing issues with the frontend application on the VM.

## Issue Description

The frontend application was failing to start due to compatibility issues with the Node.js version. The application uses the optional chaining operator (`?.`), which requires Node.js 14 or later. Additionally, the Nginx configuration was set up to proxy to port 3000, but the Nuxt.js application is actually listening on port 8080.

## Fixes Implemented

1. **Updated cloudbuild-frontend.yaml**:
   - Added installation of Node.js 16 on the VM
   - Updated Nginx configuration to proxy to port 8080 instead of port 3000
   - Added steps to rebuild the frontend application with the new Node.js version
   - Added proper cleanup and restart of the PM2 process

2. **Created Fix Scripts**:
   - `fix-frontend-vm.sh`: A script to fix the frontend issues directly on the VM
   - `fix-frontend-cloud.sh`: A script to fix the frontend issues from Cloud Shell or any other environment with access to the VM
   - `run-frontend-fix.sh`: A script to run the fix-frontend-vm.sh script on the VM

## How to Fix the Frontend

### Option 1: Deploy with Updated Cloud Build Configuration

The simplest way to fix the frontend is to deploy it using the updated Cloud Build configuration:

```bash
gcloud builds submit --config=cloudbuild-frontend.yaml
```

This will:
1. Build the frontend application
2. Deploy it to the VM
3. Install Node.js 16 on the VM
4. Configure Nginx to proxy to port 8080
5. Rebuild the frontend application with the new Node.js version
6. Start the frontend application with PM2

### Option 2: Run the Fix Script from Cloud Shell

If you don't want to redeploy the entire frontend, you can run the fix script from Cloud Shell:

```bash
chmod +x fix-frontend-cloud.sh
./fix-frontend-cloud.sh
```

This will:
1. Set up SSH access to the VM
2. Create a fix script on the VM
3. Run the fix script on the VM

### Option 3: Run the Fix Script Directly on the VM

If you have SSH access to the VM, you can run the fix script directly on the VM:

```bash
sudo bash -c "$(cat fix-frontend-vm.sh)"
```

This will:
1. Upgrade Node.js to version 16
2. Update the Nginx configuration
3. Rebuild the frontend application
4. Restart the frontend application

## Verifying the Fix

After applying the fix, you can verify that the frontend is working by:

1. Checking if the frontend application is running:
   ```bash
   sudo pm2 status
   ```

2. Checking if the application is listening on port 8080:
   ```bash
   sudo netstat -tulpn | grep 8080
   ```

3. Accessing the frontend in a web browser:
   ```
   http://<VM-IP-ADDRESS>
   ```

## Troubleshooting

If you encounter issues after applying the fix:

1. Check the PM2 logs:
   ```bash
   sudo pm2 logs frontend
   ```

2. Check the Nginx error logs:
   ```bash
   sudo tail -n 100 /var/log/nginx/error.log
   ```

3. Check the Nginx configuration:
   ```bash
   sudo nginx -t
   ```

4. Restart the frontend application:
   ```bash
   sudo pm2 restart frontend
   ```

5. Restart Nginx:
   ```bash
   sudo systemctl restart nginx
