#!/bin/bash
# Script to set up Docker deployment locally on the VM
# This is useful for testing before setting up Cloud Build

set -e  # Exit on any error

echo "Setting up Docker deployment locally on the VM..."

# Install Docker and Docker Compose if not already installed
if ! command -v docker &> /dev/null; then
  echo "Installing Docker..."
  sudo apt-get update
  sudo apt-get install -y docker.io docker-compose
  sudo systemctl enable docker
  sudo systemctl start docker
  sudo usermod -aG docker $USER
  echo "Docker installed. You may need to log out and log back in for group changes to take effect."
else
  echo "Docker is already installed."
fi

# Create a backup directory
echo "Creating backup directory..."
mkdir -p ~/baic-backup

# Backup important files
echo "Backing up important files..."
sudo cp -r /opt/baic/application*.yml ~/baic-backup/ || true
sudo cp -r /opt/baic/application*.properties ~/baic-backup/ || true
sudo cp -r /opt/baic/uploads ~/baic-backup/ || true
sudo chown -R $(whoami):$(whoami) ~/baic-backup

# Stop and disable existing services
echo "Stopping and disabling existing services..."
sudo systemctl stop baic-admin || true
sudo systemctl stop baic-web || true
sudo systemctl disable baic-admin || true
sudo systemctl disable baic-web || true

# Remove service files
echo "Removing service files..."
sudo rm -f /etc/systemd/system/baic-admin.service || true
sudo rm -f /etc/systemd/system/baic-web.service || true
sudo systemctl daemon-reload

# Clean up any existing Java processes
echo "Cleaning up existing Java processes..."
sudo pkill -f 'ruoyi-admin.jar' || true
sudo pkill -f 'ruoyi-web.jar' || true

# Build the Java applications
echo "Building Java applications..."
cd beiqi-service-master/beiqi-service-master
mvn clean package -DskipTests
cd ../..

# Create Docker Compose file
echo "Creating Docker Compose file..."
cat > ~/docker-compose.yml << EOF
version: '3'
services:
  admin-service:
    build:
      context: ./beiqi-service-master/beiqi-service-master
      dockerfile: Dockerfile.admin
    ports:
      - "8080:8080"
    environment:
      - SPRING_DATASOURCE_URL=jdbc:mysql://127.0.0.1:3306/baicintl?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=false&serverTimezone=GMT%2B8
      - SPRING_DATASOURCE_USERNAME=ruoyi
      - SPRING_DATASOURCE_PASSWORD=Stellies21!@
      - SPRING_PROFILES_ACTIVE=prod
      - SPRING_MAIN_ALLOW_BEAN_DEFINITION_OVERRIDING=true
    volumes:
      - /opt/baic/uploads:/app/uploads
    network_mode: "host"
    restart: always

  web-service:
    build:
      context: ./beiqi-service-master/beiqi-service-master
      dockerfile: Dockerfile.web
    ports:
      - "8081:8080"
    environment:
      - SPRING_DATASOURCE_URL=jdbc:mysql://127.0.0.1:3306/baicintl?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=false&serverTimezone=GMT%2B8
      - SPRING_DATASOURCE_USERNAME=ruoyi
      - SPRING_DATASOURCE_PASSWORD=Stellies21!@
      - SPRING_PROFILES_ACTIVE=prod
      - SPRING_MAIN_ALLOW_BEAN_DEFINITION_OVERRIDING=true
    volumes:
      - /opt/baic/uploads:/app/uploads
    network_mode: "host"
    restart: always
EOF

# Copy Dockerfiles
echo "Copying Dockerfiles..."
cp beiqi-service-master/beiqi-service-master/Dockerfile.admin ~/Dockerfile.admin
cp beiqi-service-master/beiqi-service-master/Dockerfile.web ~/Dockerfile.web

# Create uploads directory if it doesn't exist
echo "Creating uploads directory..."
sudo mkdir -p /opt/baic/uploads
sudo chmod -R 777 /opt/baic/uploads

# Deploy with Docker Compose
echo "Deploying with Docker Compose..."
cd ~
sudo docker-compose down || true
sudo docker-compose up -d

# Check if the containers are running
echo "Checking if the containers are running..."
sudo docker ps

# Check container logs
echo "Checking container logs..."
echo "Admin service logs:"
sudo docker logs $(sudo docker ps -q --filter 'name=admin-service') || true
echo "Web service logs:"
sudo docker logs $(sudo docker ps -q --filter 'name=web-service') || true

echo "Docker deployment completed!"
echo "You can access the services at:"
echo "Admin Backend: http://localhost:8080/api"
echo "Web Backend: http://localhost:8080/home-api"
