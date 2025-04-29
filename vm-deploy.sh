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
  # Specify the username to use for SSH
  SSH_USER="cloudbuild"
  
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
    gcloud compute ssh ${SSH_USER}@${VM_NAME} --zone=${VM_ZONE} --command="sudo bash -c 'cat > /etc/systemd/system/${ADMIN_SERVICE}.service << EOF
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

    gcloud compute ssh ${SSH_USER}@${VM_NAME} --zone=${VM_ZONE} --command="sudo bash -c 'cat > /etc/systemd/system/${WEB_SERVICE}.service << EOF
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
    gcloud compute ssh ${SSH_USER}@${VM_NAME} --zone=${VM_ZONE} --command="sudo systemctl daemon-reload && sudo systemctl enable ${ADMIN_SERVICE} && sudo systemctl enable ${WEB_SERVICE}"
    
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
  
  # Specify the username to use for SSH
  SSH_USER="cloudbuild"
  
  # Ensure remote directory exists and has proper permissions
  echo "Ensuring remote directory exists..."
  gcloud compute ssh ${SSH_USER}@${VM_NAME} --zone=${VM_ZONE} --command="sudo mkdir -p ${REMOTE_DIR} ${REMOTE_DIR}/logs && sudo chmod 777 ${REMOTE_DIR}"
  
  # Create a setup script for the systemd services
  echo "Creating setup script for systemd services..."
  cat > setup-services.sh << 'EOFLOCAL'
#!/bin/bash
ADMIN_SERVICE="baic-admin"
WEB_SERVICE="baic-web"

if [ ! -f /etc/systemd/system/$ADMIN_SERVICE.service ]; then
  echo "Creating $ADMIN_SERVICE service file..."
  sudo bash -c "cat > /etc/systemd/system/$ADMIN_SERVICE.service << EOF
[Unit]
Description=BAIC Admin Backend Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/baic
Environment=\"JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64\"
Environment=\"PATH=/usr/lib/jvm/java-8-openjdk-amd64/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"
ExecStart=/usr/lib/jvm/java-8-openjdk-amd64/bin/java -Xms1024m -Xmx2048m -jar /opt/baic/ruoyi-admin.jar --spring.profiles.active=prod
Restart=always
RestartSec=10
StandardOutput=file:/opt/baic/logs/admin.log
StandardError=file:/opt/baic/logs/admin-error.log

[Install]
WantedBy=multi-user.target
EOF"
fi

if [ ! -f /etc/systemd/system/$WEB_SERVICE.service ]; then
  echo "Creating $WEB_SERVICE service file..."
  sudo bash -c "cat > /etc/systemd/system/$WEB_SERVICE.service << EOF
[Unit]
Description=BAIC Web Backend Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/baic
Environment=\"JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64\"
Environment=\"PATH=/usr/lib/jvm/java-8-openjdk-amd64/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"
ExecStart=/usr/lib/jvm/java-8-openjdk-amd64/bin/java -Xms1024m -Xmx2048m -jar /opt/baic/ruoyi-web.jar --spring.profiles.active=prod
Restart=always
RestartSec=10
StandardOutput=file:/opt/baic/logs/web.log
StandardError=file:/opt/baic/logs/web-error.log

[Install]
WantedBy=multi-user.target
EOF"
fi

# Reload systemd and enable services
sudo systemctl daemon-reload
sudo systemctl enable $ADMIN_SERVICE
sudo systemctl enable $WEB_SERVICE
EOFLOCAL

  # Make the script executable
  chmod +x setup-services.sh
  
  # Copy the script to the VM
  echo "Copying setup script to VM..."
  gcloud compute scp setup-services.sh ${SSH_USER}@${VM_NAME}:~/setup-services.sh --zone=${VM_ZONE}
  
  # Execute the script on the VM
  echo "Executing setup script on VM..."
  gcloud compute ssh ${SSH_USER}@${VM_NAME} --zone=${VM_ZONE} --command="chmod +x ~/setup-services.sh && ~/setup-services.sh"
  
  # Clean up the script
  rm setup-services.sh
  
  # Copy JAR files to VM - first to home directory, then move to final location
  echo "Copying ${ADMIN_JAR_PATH} to VM..."
  gcloud compute scp ${ADMIN_JAR_PATH} ${SSH_USER}@${VM_NAME}:~/ruoyi-admin.jar --zone=${VM_ZONE}
  
  echo "Copying ${WEB_JAR_PATH} to VM..."
  gcloud compute scp ${WEB_JAR_PATH} ${SSH_USER}@${VM_NAME}:~/ruoyi-web.jar --zone=${VM_ZONE}
  
  # Create a setup script for Java and JAR files
  echo "Creating setup script for Java and JAR files..."
  cat > setup-java.sh << 'EOFLOCAL'
#!/bin/bash
set -e

# Install Java 8 explicitly
echo "Installing Java 8..."
sudo apt-get update
sudo apt-get install -y openjdk-8-jdk || sudo apt-get install -y openjdk-11-jdk

# Find Java installation path
JAVA_PATH=$(sudo update-alternatives --display java | grep -o '^/.*java$' | head -n1 | sed 's/bin\/java$//')
if [ -z "$JAVA_PATH" ]; then
  JAVA_PATH="/usr/lib/jvm/java-8-openjdk-amd64/"
fi
echo "Java installation path: $JAVA_PATH"

# Set JAVA_HOME
export JAVA_HOME=$JAVA_PATH
echo "Setting JAVA_HOME=$JAVA_HOME"
sudo bash -c "echo 'JAVA_HOME=$JAVA_HOME' >> /etc/environment"

# Verify Java installation
echo "Verifying Java installation..."
java -version
which java
echo "Java home: $JAVA_HOME"

# Make sure Java is in the PATH
export PATH=$JAVA_HOME/bin:$PATH

# Move JAR files to the proper location with correct permissions
echo "Moving JAR files to the proper location..."
sudo mv ~/ruoyi-admin.jar /opt/baic/ruoyi-admin.jar
sudo mv ~/ruoyi-web.jar /opt/baic/ruoyi-web.jar
sudo chmod 755 /opt/baic/ruoyi-admin.jar
sudo chmod 755 /opt/baic/ruoyi-web.jar
sudo chown -R root:root /opt/baic

# Verify JAR files
echo "Verifying JAR files..."
ls -la /opt/baic/
file /opt/baic/ruoyi-admin.jar
file /opt/baic/ruoyi-web.jar

# Restart services
echo "Restarting services..."
sudo systemctl restart baic-admin
sudo systemctl restart baic-web
EOFLOCAL

  # Make the script executable
  chmod +x setup-java.sh
  
  # Copy the script to the VM
  echo "Copying Java setup script to VM..."
  gcloud compute scp setup-java.sh ${SSH_USER}@${VM_NAME}:~/setup-java.sh --zone=${VM_ZONE}
  
  # Execute the script on the VM
  echo "Executing Java setup script on VM..."
  gcloud compute ssh ${SSH_USER}@${VM_NAME} --zone=${VM_ZONE} --command="chmod +x ~/setup-java.sh && ~/setup-java.sh"
  
  # Clean up the script
  rm setup-java.sh
  
  # Check service status
  echo "Checking service status..."
  gcloud compute ssh ${SSH_USER}@${VM_NAME} --zone=${VM_ZONE} --command="sudo systemctl status ${ADMIN_SERVICE} && sudo systemctl status ${WEB_SERVICE}"
}

# Main execution
echo "Starting deployment to VM..."
create_vm_if_needed
deploy_jars
echo "Deployment completed successfully!"

# Print access information
SSH_USER="cloudbuild"
EXTERNAL_IP=$(gcloud compute instances describe ${VM_NAME} --zone=${VM_ZONE} --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
echo "Services are now available at:"
echo "Admin Backend: http://${EXTERNAL_IP}:8080"
echo "Web Backend: http://${EXTERNAL_IP}:8080"
echo "Note: You may need to configure a load balancer or DNS entries for production use."
