#!/bin/bash
# Script to fix the service files on the VM

set -e  # Exit on any error

# Configuration
VM_NAME="baic-backend-vm"
VM_ZONE="us-central1-a"
SSH_USER="cloudbuild"

echo "Fixing service files on VM ${VM_NAME}..."

# Create a script to update the service files
cat > update-services.sh << 'EOFLOCAL'
#!/bin/bash
set -e

# Update the application-dev.yml files to use the correct database URL
echo "Updating application-dev.yml files..."
sudo bash -c "cat > /opt/baic/application-dev-admin.yml << EOF
# Spring configuration
spring:
  # Database configuration
  datasource:
    type: com.alibaba.druid.pool.DruidDataSource
    driverClassName: com.mysql.cj.jdbc.Driver
    druid:
      # Master database
      master:
        url: jdbc:mysql://34.69.17.6:3306/ruoyi?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=false&serverTimezone=GMT%2B8
        username: ruoyi
        password: Stellies21!@
      # Slave database
      slave:
        # Whether to enable slave database
        enabled: false
EOF"

sudo bash -c "cat > /opt/baic/application-dev-web.yml << EOF
# Spring configuration
spring:
  # Database configuration
  datasource:
    type: com.alibaba.druid.pool.DruidDataSource
    driverClassName: com.mysql.cj.jdbc.Driver
    druid:
      # Master database
      master:
        url: jdbc:mysql://34.69.17.6:3306/ruoyi?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=false&serverTimezone=GMT%2B8
        username: ruoyi
        password: Stellies21!@
      # Slave database
      slave:
        # Whether to enable slave database
        enabled: false
EOF"

# Update the admin service file
echo "Updating baic-admin.service..."
sudo bash -c "cat > /etc/systemd/system/baic-admin.service << EOF
[Unit]
Description=BAIC Admin Backend Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/baic
Environment=\"JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64\"
Environment=\"PATH=/usr/lib/jvm/java-11-openjdk-amd64/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"
ExecStart=/usr/bin/java -Xms1024m -Xmx2048m -jar /opt/baic/ruoyi-admin.jar --spring.profiles.active=prod --spring.config.location=file:/opt/baic/application-prod-admin.yml
Restart=always
RestartSec=10
StandardOutput=file:/opt/baic/logs/admin.log
StandardError=file:/opt/baic/logs/admin-error.log

[Install]
WantedBy=multi-user.target
EOF"

# Update the web service file
echo "Updating baic-web.service..."
sudo bash -c "cat > /etc/systemd/system/baic-web.service << EOF
[Unit]
Description=BAIC Web Backend Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/baic
Environment=\"JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64\"
Environment=\"PATH=/usr/lib/jvm/java-11-openjdk-amd64/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"
ExecStart=/usr/bin/java -Xms1024m -Xmx2048m -jar /opt/baic/ruoyi-web.jar --spring.profiles.active=prod --spring.config.location=file:/opt/baic/application-prod-web.yml
Restart=always
RestartSec=10
StandardOutput=file:/opt/baic/logs/web.log
StandardError=file:/opt/baic/logs/web-error.log

[Install]
WantedBy=multi-user.target
EOF"

# Reload systemd and restart services
echo "Reloading systemd and restarting services..."
sudo systemctl daemon-reload
sudo systemctl restart baic-admin
sudo systemctl restart baic-web

# Check service status
echo "Checking service status..."
sudo systemctl status baic-admin
sudo systemctl status baic-web

echo "Done!"
EOFLOCAL

# Make the script executable
chmod +x update-services.sh

# Copy the script to the VM
echo "Copying script to VM..."
gcloud compute scp update-services.sh ${SSH_USER}@${VM_NAME}:~/update-services.sh --zone=${VM_ZONE}

# Execute the script on the VM
echo "Executing script on VM..."
gcloud compute ssh ${SSH_USER}@${VM_NAME} --zone=${VM_ZONE} --command="chmod +x ~/update-services.sh && ~/update-services.sh"

# Clean up the script
rm update-services.sh

echo "Service files fixed successfully!"
