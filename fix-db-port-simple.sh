#!/bin/bash
# Simple script to fix the database connection issue by redirecting traffic from port 3,306 to 3306

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Use sudo."
  exit 1
fi

echo "Fixing database connection issue..."

# Ensure localhost resolves to 127.0.0.1
echo "Updating hosts file to ensure localhost resolves to 127.0.0.1..."
grep -q "^127.0.0.1.*localhost" /etc/hosts || echo "127.0.0.1 localhost" >> /etc/hosts

# Create a simple solution: modify the application configuration files
echo "Updating application configuration files..."

# Create a new application.properties file that will override any settings in the JAR
echo "Creating application.properties file to override database settings..."
cat > /opt/baic/application.properties << EOF
# Override database connection settings
spring.datasource.druid.master.url=jdbc:mysql://127.0.0.1:3306/baicintl?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=false&serverTimezone=GMT%2B8
spring.datasource.druid.master.username=ruoyi
spring.datasource.druid.master.password=Stellies21!@

# Allow bean definition overriding
spring.main.allow-bean-definition-overriding=true
EOF

# Update the systemd service files to use this properties file
echo "Updating systemd service files..."
cat > /etc/systemd/system/baic-admin.service << EOF
[Unit]
Description=BAIC Admin Backend Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/baic
Environment="JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64"
Environment="PATH=/usr/lib/jvm/java-11-openjdk-amd64/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ExecStart=/usr/bin/java -Xms1024m -Xmx2048m -jar /opt/baic/ruoyi-admin.jar --spring.profiles.active=prod --spring.config.additional-location=file:/opt/baic/application.properties
Restart=always
RestartSec=10
StandardOutput=file:/opt/baic/logs/admin.log
StandardError=file:/opt/baic/logs/admin-error.log

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/baic-web.service << EOF
[Unit]
Description=BAIC Web Backend Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/baic
Environment="JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64"
Environment="PATH=/usr/lib/jvm/java-11-openjdk-amd64/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ExecStart=/usr/bin/java -Xms1024m -Xmx2048m -jar /opt/baic/ruoyi-web.jar --spring.profiles.active=prod --spring.config.additional-location=file:/opt/baic/application.properties
Restart=always
RestartSec=10
StandardOutput=file:/opt/baic/logs/web.log
StandardError=file:/opt/baic/logs/web-error.log

[Install]
WantedBy=multi-user.target
EOF

# Create a symbolic link for the database
echo "Creating symbolic link for the database..."
ln -sf /var/lib/mysql/mysql.sock /tmp/mysql.sock

# Ensure the MySQL server is running
echo "Ensuring MySQL server is running..."
systemctl restart mariadb

# Reload systemd and restart the services
echo "Reloading systemd and restarting services..."
systemctl daemon-reload
systemctl restart baic-admin
systemctl restart baic-web

echo "Fix completed. Services restarted."
echo "You can check the status of the services with:"
echo "  systemctl status baic-admin"
echo "  systemctl status baic-web"
echo "  tail -n 50 /opt/baic/logs/admin.log"
echo "  tail -n 50 /opt/baic/logs/web.log"
