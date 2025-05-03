# Instructions for Running the Nginx Fix Script on the VM

## Option 1: If you're already logged into the VM

1. Copy the contents of the `fix-nginx-config-direct.sh` script
2. Create a new file on the VM:
   ```bash
   nano fix-nginx.sh
   ```
3. Paste the contents into the file
4. Save the file (Ctrl+O, then Enter, then Ctrl+X)
5. Make the script executable:
   ```bash
   chmod +x fix-nginx.sh
   ```
6. Run the script with sudo:
   ```bash
   sudo ./fix-nginx.sh
   ```

## Option 2: Using Cloud Shell to run the script on the VM

1. Open Google Cloud Shell
2. Copy the contents of the `run-fix-nginx-config.sh` and `fix-nginx-config.sh` scripts
3. Create these files in Cloud Shell:
   ```bash
   nano run-fix-nginx-config.sh
   # Paste the contents, save and exit (Ctrl+O, Enter, Ctrl+X)
   
   nano fix-nginx-config.sh
   # Paste the contents, save and exit (Ctrl+O, Enter, Ctrl+X)
   ```
4. Make the scripts executable:
   ```bash
   chmod +x run-fix-nginx-config.sh fix-nginx-config.sh
   ```
5. Run the script:
   ```bash
   ./run-fix-nginx-config.sh
   ```

## Option 3: Using gcloud commands directly

If you're already logged into the VM, you can run these commands directly:

```bash
# Create the Nginx configuration
sudo bash -c 'cat > /etc/nginx/sites-available/main << EOF
# Default server for the frontend
server {
    listen 80 default_server;
    server_name _;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
    
    location /api/ {
        proxy_pass http://localhost:8080/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
    
    location /home-api/ {
        proxy_pass http://localhost:8080/home-api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
    
    # Admin panel access via subdirectory
    location /admin/ {
        alias /var/www/admin/;
        try_files \$uri \$uri/ /admin/index.html;
    }
}
EOF'

# Enable the new configuration
sudo ln -sf /etc/nginx/sites-available/main /etc/nginx/sites-enabled/

# Remove old configurations
sudo rm -f /etc/nginx/sites-enabled/admin
sudo rm -f /etc/nginx/sites-enabled/frontend
sudo rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

# Restart frontend application
sudo pm2 restart frontend
```

After running any of these options, you should be able to access:
- Frontend: http://YOUR-VM-IP
- Admin panel: http://YOUR-VM-IP/admin/
