#!/bin/bash
# VM setup script for BAIC Global application

# Update package lists
sudo apt-get update

# Install required packages
sudo apt-get install -y nginx nodejs npm mariadb-server

# Install PM2 globally
sudo npm install -g pm2

# Configure Nginx
sudo bash -c 'cat > /etc/nginx/nginx.conf << EOF
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 768;
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    gzip on;

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOF'

# Create directories for applications
sudo mkdir -p /var/www/frontend
sudo mkdir -p /var/www/admin
sudo mkdir -p /opt/baic/uploads

# Set proper permissions
sudo chown -R www-data:www-data /var/www
sudo chmod -R 755 /var/www
sudo chown -R www-data:www-data /opt/baic/uploads
sudo chmod -R 755 /opt/baic/uploads

# Enable and start Nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Enable and start MariaDB
sudo systemctl enable mariadb
sudo systemctl start mariadb

# Create database and user
sudo mysql -e "CREATE DATABASE IF NOT EXISTS baicintl;"
sudo mysql -e "CREATE USER IF NOT EXISTS 'ruoyi'@'localhost' IDENTIFIED BY 'Stellies21!@';"
sudo mysql -e "GRANT ALL PRIVILEGES ON baicintl.* TO 'ruoyi'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Try to download and import the SQL file from Cloud Storage
echo "Trying to download and import the SQL file from Cloud Storage..."
gsutil cp gs://baic-sql-files-457613/baicintl_backup.sql /tmp/baicintl_backup.sql || echo "SQL file not found, skipping import"
if [ -f /tmp/baicintl_backup.sql ]; then
  echo "Importing SQL file..."
  sed -i 's/utf8mb4_0900_ai_ci/utf8mb4_general_ci/g' /tmp/baicintl_backup.sql
  sudo mysql baicintl < /tmp/baicintl_backup.sql || echo "Error importing SQL file, continuing anyway"
  rm /tmp/baicintl_backup.sql
fi

# Configure firewall to allow HTTP and HTTPS traffic
sudo apt-get install -y ufw
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8080/tcp
sudo ufw --force enable

echo "VM setup completed successfully!"
