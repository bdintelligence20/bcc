#!/bin/bash
# Simplified VM deployment script for BAIC Global Java backend services

set -e  # Exit on any error

# Hardcoded configuration
VM_NAME="baic-backend-vm"
VM_ZONE="us-central1-a"
ADMIN_JAR_PATH="beiqi-service-master/beiqi-service-master/ruoyi-admin/target/ruoyi-admin.jar"
WEB_JAR_PATH="beiqi-service-master/beiqi-service-master/ruoyi-web/target/ruoyi-web.jar"
REMOTE_DIR="/opt/baic"
ADMIN_SERVICE="baic-admin"
WEB_SERVICE="baic-web"

# Use absolute paths for SSH keys
SSH_DIR="/root/.ssh"
SSH_KEY="${SSH_DIR}/google_compute_engine"
SSH_KEY_PUB="${SSH_KEY}.pub"

echo "Starting simplified deployment to VM $VM_NAME in zone $VM_ZONE..."

# Verify SSH key exists
if [ ! -f "$SSH_KEY" ]; then
  echo "SSH key not found at $SSH_KEY. Generating new key..."
  mkdir -p "$SSH_DIR"
  ssh-keygen -t rsa -f "$SSH_KEY" -N "" -q
fi

# Display SSH key for debugging
echo "Using SSH key:"
cat "$SSH_KEY_PUB"

# Setup VM if needed
echo "Setting up VM..."
gcloud compute ssh "$VM_NAME" --zone="$VM_ZONE" --command="sudo mkdir -p $REMOTE_DIR $REMOTE_DIR/logs && sudo chmod 777 $REMOTE_DIR"

# Install Java if needed
echo "Ensuring Java is installed..."
gcloud compute ssh "$VM_NAME" --zone="$VM_ZONE" --command="which java || sudo apt-get update && sudo apt-get install -y openjdk-8-jdk"

# Create systemd service files if they don't exist
echo "Setting up systemd services..."
gcloud compute ssh "$VM_NAME" --zone="$VM_ZONE" --command="
if [ ! -f /etc/systemd/system/$ADMIN_SERVICE.service ]; then
  sudo bash -c 'cat > /etc/systemd/system/$ADMIN_SERVICE.service << EOF
[Unit]
Description=BAIC Admin Backend Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$REMOTE_DIR
ExecStart=/usr/bin/java -Xms1024m -Xmx2048m -jar $REMOTE_DIR/ruoyi-admin.jar --spring.profiles.active=prod
Restart=always
RestartSec=10
StandardOutput=file:$REMOTE_DIR/logs/admin.log
StandardError=file:$REMOTE_DIR/logs/admin-error.log

[Install]
WantedBy=multi-user.target
EOF'
fi

if [ ! -f /etc/systemd/system/$WEB_SERVICE.service ]; then
  sudo bash -c 'cat > /etc/systemd/system/$WEB_SERVICE.service << EOF
[Unit]
Description=BAIC Web Backend Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$REMOTE_DIR
ExecStart=/usr/bin/java -Xms1024m -Xmx2048m -jar $REMOTE_DIR/ruoyi-web.jar --spring.profiles.active=prod
Restart=always
RestartSec=10
StandardOutput=file:$REMOTE_DIR/logs/web.log
StandardError=file:$REMOTE_DIR/logs/web-error.log

[Install]
WantedBy=multi-user.target
EOF'
fi

sudo systemctl daemon-reload
sudo systemctl enable $ADMIN_SERVICE
sudo systemctl enable $WEB_SERVICE
"

# Copy JAR files to VM
echo "Copying JAR files to VM..."
gcloud compute scp "$ADMIN_JAR_PATH" "$VM_NAME":~/ruoyi-admin.jar --zone="$VM_ZONE"
gcloud compute scp "$WEB_JAR_PATH" "$VM_NAME":~/ruoyi-web.jar --zone="$VM_ZONE"

# Move JAR files to the proper location
echo "Moving JAR files to the proper location..."
gcloud compute ssh "$VM_NAME" --zone="$VM_ZONE" --command="sudo mv ~/ruoyi-admin.jar $REMOTE_DIR/ruoyi-admin.jar && sudo mv ~/ruoyi-web.jar $REMOTE_DIR/ruoyi-web.jar && sudo chown -R root:root $REMOTE_DIR"

# Restart services
echo "Restarting services..."
gcloud compute ssh "$VM_NAME" --zone="$VM_ZONE" --command="sudo systemctl restart $ADMIN_SERVICE && sudo systemctl restart $WEB_SERVICE"

# Check service status
echo "Checking service status..."
gcloud compute ssh "$VM_NAME" --zone="$VM_ZONE" --command="sudo systemctl status $ADMIN_SERVICE && sudo systemctl status $WEB_SERVICE"

# Print access information
EXTERNAL_IP=$(gcloud compute instances describe "$VM_NAME" --zone="$VM_ZONE" --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
echo "Services are now available at:"
echo "Admin Backend: http://$EXTERNAL_IP:8080"
echo "Web Backend: http://$EXTERNAL_IP:8080"
echo "Deployment completed successfully!"
