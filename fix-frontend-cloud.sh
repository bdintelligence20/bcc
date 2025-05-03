#!/bin/bash
# Script to fix frontend issues on the VM from Cloud Shell

# Exit on any error
set -e

# Set VM details
VM_NAME="baic-backend-vm"
VM_ZONE="us-central1-a"

echo "Setting up SSH..."
mkdir -p ~/.ssh
ssh-keygen -t rsa -f ~/.ssh/google_compute_engine -N "" -q || true

echo "Adding SSH key to VM metadata..."
gcloud compute instances add-metadata ${VM_NAME} --zone=${VM_ZONE} --metadata="ssh-keys=cloudbuild:$(cat ~/.ssh/google_compute_engine.pub)"

echo "Configuring SSH..."
cat > ~/.ssh/config << EOF
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
EOF
chmod 600 ~/.ssh/config

echo "Waiting for SSH key propagation..."
sleep 30

echo "Creating fix script on VM..."
gcloud compute ssh cloudbuild@${VM_NAME} --zone=${VM_ZONE} --command="sudo bash -c 'cat > /tmp/fix-frontend.sh << EOF
#!/bin/bash
# Script to fix frontend issues on the VM

# Exit on any error
set -e

echo \"Upgrading Node.js to version 16...\"
curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
apt-get install -y nodejs

echo \"Checking Node.js version...\"
node -v

echo \"Updating Nginx configuration...\"
cat > /etc/nginx/sites-available/frontend << EOF2
server {
    listen 80;
    server_name _;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \\\\$http_upgrade;
        proxy_set_header Connection \"upgrade\";
        proxy_set_header Host \\\\$host;
        proxy_cache_bypass \\\\$http_upgrade;
    }
    
    location /api/ {
        proxy_pass http://localhost:8080/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \\\\$http_upgrade;
        proxy_set_header Connection \"upgrade\";
        proxy_set_header Host \\\\$host;
        proxy_cache_bypass \\\\$http_upgrade;
    }
    
    location /home-api/ {
        proxy_pass http://localhost:8080/home-api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \\\\$http_upgrade;
        proxy_set_header Connection \"upgrade\";
        proxy_set_header Host \\\\$host;
        proxy_cache_bypass \\\\$http_upgrade;
    }
}
EOF2

echo \"Enabling the site...\"
ln -sf /etc/nginx/sites-available/frontend /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

echo \"Testing Nginx configuration...\"
nginx -t

echo \"Restarting Nginx...\"
systemctl restart nginx

echo \"Rebuilding frontend application...\"
cd /var/www/frontend
npm rebuild

echo \"Restarting frontend application...\"
pm2 delete frontend || true
pm2 start npm --name \"frontend\" -- run start

echo \"Checking if frontend is running...\"
pm2 status
netstat -tulpn | grep 8080

echo \"Fix completed successfully!\"
EOF'"

echo "Making fix script executable on VM..."
gcloud compute ssh cloudbuild@${VM_NAME} --zone=${VM_ZONE} --command="sudo chmod +x /tmp/fix-frontend.sh"

echo "Running fix script on VM..."
gcloud compute ssh cloudbuild@${VM_NAME} --zone=${VM_ZONE} --command="sudo /tmp/fix-frontend.sh"

echo "Frontend fix completed successfully!"
