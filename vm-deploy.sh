#!/bin/bash
# VM deployment script for BAIC Global Java backend services
# This script is executed by Cloud Build to deploy JAR files to a Compute Engine VM

set -e  # Exit on any error

# Configuration
VM_NAME="baic-backend-vm"
VM_ZONE="us-central1-a"
ADMIN_JAR_PATH="beiqi-service-master/beiqi-service-master/ruoyi-admin/target/ruoyi-admin.jar"
WEB_JAR_PATH="beiqi-service-master/beiqi-service-master/ruoyi-web/target/ruoyi-web.jar"
REMOTE_DIR="/opt/baic"
ADMIN_SERVICE="baic-admin"
WEB_SERVICE="baic-web"

# Function to check if VM exists
check_vm_exists() {
  echo "Checking if VM ${VM_NAME} exists..."
  if gcloud compute instances describe ${VM_NAME} --zone=${VM_ZONE} &>/dev/null; then
    echo "VM ${VM_NAME} exists."
    return 0
  else
    echo "VM ${VM_NAME} does not exist."
    return 1
  fi
}

# Function to create VM if it doesn't exist
create_vm_if_needed() {
  if ! check_vm_exists; then
    echo "Creating VM ${VM_NAME}..."
    gcloud compute instances create ${VM_NAME} \
      --zone=${VM_ZONE} \
      --machine-type=e2-standard-2 \
      --boot-disk-size=20GB \
      --image-family=debian-11 \
      --image-project=debian-cloud \
      --tags=http-server,https-server \
      --metadata=startup-script='#! /bin/bash
        apt-get update
        apt-get install -y openjdk-8-jdk
        mkdir -p /opt/baic
        mkdir -p /opt/baic/logs
      '
    
    # Wait for VM to be ready
    echo "Waiting for VM to be ready..."
    sleep 60
    
    # Create systemd service files
    echo "Creating systemd service files..."
    gcloud compute ssh ${VM_NAME} --zone=${VM_ZONE} --command="sudo bash -c 'cat > /etc/systemd/system/${ADMIN_SERVICE}.service << EOF
[Unit]
Description=BAIC Admin Backend Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/baic
ExecStart=/usr/bin/java -Xms1024m -Xmx2048m -jar /opt/baic/ruoyi-admin.jar --spring.profiles.active=prod
Restart=always
RestartSec=10
StandardOutput=file:/opt/baic/logs/admin.log
StandardError=file:/opt/baic/logs/admin-error.log

[Install]
WantedBy=multi-user.target
EOF'"

    gcloud compute ssh ${VM_NAME} --zone=${VM_ZONE} --command="sudo bash -c 'cat > /etc/systemd/system/${WEB_SERVICE}.service << EOF
[Unit]
Description=BAIC Web Backend Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/baic
ExecStart=/usr/bin/java -Xms1024m -Xmx2048m -jar /opt/baic/ruoyi-web.jar --spring.profiles.active=prod
Restart=always
RestartSec=10
StandardOutput=file:/opt/baic/logs/web.log
StandardError=file:/opt/baic/logs/web-error.log

[Install]
WantedBy=multi-user.target
EOF'"

    # Enable services
    gcloud compute ssh ${VM_NAME} --zone=${VM_ZONE} --command="sudo systemctl daemon-reload && sudo systemctl enable ${ADMIN_SERVICE} && sudo systemctl enable ${WEB_SERVICE}"
    
    # Configure firewall rules
    echo "Configuring firewall rules..."
    gcloud compute firewall-rules create allow-http \
      --allow tcp:80,tcp:8080 \
      --target-tags=http-server \
      --description="Allow HTTP traffic" \
      --direction=INGRESS
    
    gcloud compute firewall-rules create allow-https \
      --allow tcp:443 \
      --target-tags=https-server \
      --description="Allow HTTPS traffic" \
      --direction=INGRESS
  fi
}

# Function to deploy JAR files to VM
deploy_jars() {
  echo "Deploying JAR files to VM..."
  
  # Ensure remote directory exists and has proper permissions
  echo "Ensuring remote directory exists..."
  gcloud compute ssh ${VM_NAME} --zone=${VM_ZONE} --command="sudo mkdir -p ${REMOTE_DIR} && sudo chmod 777 ${REMOTE_DIR}"
  
  # Copy JAR files to VM - first to home directory, then move to final location
  echo "Copying ${ADMIN_JAR_PATH} to VM..."
  gcloud compute scp ${ADMIN_JAR_PATH} ${VM_NAME}:~/ruoyi-admin.jar --zone=${VM_ZONE}
  
  echo "Copying ${WEB_JAR_PATH} to VM..."
  gcloud compute scp ${WEB_JAR_PATH} ${VM_NAME}:~/ruoyi-web.jar --zone=${VM_ZONE}
  
  # Move JAR files to the proper location
  echo "Moving JAR files to the proper location..."
  gcloud compute ssh ${VM_NAME} --zone=${VM_ZONE} --command="sudo mv ~/ruoyi-admin.jar ${REMOTE_DIR}/ruoyi-admin.jar && sudo mv ~/ruoyi-web.jar ${REMOTE_DIR}/ruoyi-web.jar && sudo chown -R root:root ${REMOTE_DIR}"
  
  # Restart services
  echo "Restarting services..."
  gcloud compute ssh ${VM_NAME} --zone=${VM_ZONE} --command="sudo systemctl restart ${ADMIN_SERVICE} && sudo systemctl restart ${WEB_SERVICE}"
  
  # Check service status
  echo "Checking service status..."
  gcloud compute ssh ${VM_NAME} --zone=${VM_ZONE} --command="sudo systemctl status ${ADMIN_SERVICE} && sudo systemctl status ${WEB_SERVICE}"
}

# Main execution
echo "Starting deployment to VM..."
create_vm_if_needed
deploy_jars
echo "Deployment completed successfully!"

# Print access information
EXTERNAL_IP=$(gcloud compute instances describe ${VM_NAME} --zone=${VM_ZONE} --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
echo "Services are now available at:"
echo "Admin Backend: http://${EXTERNAL_IP}:8080"
echo "Web Backend: http://${EXTERNAL_IP}:8080"
echo "Note: You may need to configure a load balancer or DNS entries for production use."
