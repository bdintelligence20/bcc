#!/bin/bash
# Script to fix frontend issues on the VM

# Exit on any error
set -e

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Use sudo."
  exit 1
fi

echo "Upgrading Node.js to version 16..."
curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
apt-get install -y nodejs

echo "Checking Node.js version..."
node -v

echo "Updating Nginx configuration..."
cat > /etc/nginx/sites-available/frontend << EOF
server {
    listen 80;
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
}
EOF

echo "Enabling the site..."
ln -sf /etc/nginx/sites-available/frontend /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

echo "Testing Nginx configuration..."
nginx -t

echo "Restarting Nginx..."
systemctl restart nginx

echo "Rebuilding frontend application..."
cd /var/www/frontend
npm rebuild

echo "Restarting frontend application..."
pm2 delete frontend || true
pm2 start npm --name "frontend" -- run start

echo "Checking if frontend is running..."
pm2 status
netstat -tulpn | grep 8080

echo "Fix completed successfully!"
