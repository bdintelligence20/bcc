#!/bin/bash
# Script to fix Nginx configuration for BAIC Global (to be run directly on the VM)

# Exit on any error
set -e

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Use sudo."
  exit 1
fi

echo "Creating new Nginx configuration..."
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

echo "Enabling new configuration..."
sudo ln -sf /etc/nginx/sites-available/main /etc/nginx/sites-enabled/

echo "Removing old configurations..."
sudo rm -f /etc/nginx/sites-enabled/admin
sudo rm -f /etc/nginx/sites-enabled/frontend
sudo rm -f /etc/nginx/sites-enabled/default

echo "Testing Nginx configuration..."
sudo nginx -t

echo "Restarting Nginx..."
sudo systemctl restart nginx

echo "Checking if frontend application is running..."
if ! sudo pm2 status | grep -q "frontend"; then
  echo "Starting frontend application..."
  cd /var/www/frontend
  sudo pm2 start npm --name "frontend" -- run start
else
  echo "Restarting frontend application..."
  sudo pm2 restart frontend
fi

echo "Configuration completed successfully!"
echo "You can now access:"
echo "- Frontend: http://YOUR-VM-IP"
echo "- Admin panel: http://YOUR-VM-IP/admin/"

# Get the VM's external IP address
EXTERNAL_IP=$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip -H "Metadata-Flavor: Google")
if [ ! -z "$EXTERNAL_IP" ]; then
  echo "Your VM's external IP address is: $EXTERNAL_IP"
  echo "You can access:"
  echo "- Frontend: http://$EXTERNAL_IP"
  echo "- Admin panel: http://$EXTERNAL_IP/admin/"
fi
