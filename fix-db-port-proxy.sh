#!/bin/bash
# Script to create a proxy that redirects connections from localhost:3,306 to localhost:3306

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Use sudo."
  exit 1
fi

# Install socat if not already installed
apt-get update
apt-get install -y socat

# Kill any existing socat processes
pkill -f "socat TCP-LISTEN:3306"

# Start a proxy that redirects connections from port 3306 to 3306
# This will intercept connections to the correct port and forward them to the MySQL server
echo "Starting proxy on port 3306 to redirect to MySQL server..."
socat TCP-LISTEN:3306,fork TCP:127.0.0.1:3306 &
SOCAT_PID=$!

# Create a systemd service to ensure the proxy starts on boot
cat > /etc/systemd/system/db-port-proxy.service << EOF
[Unit]
Description=Database Port Proxy Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/socat TCP-LISTEN:3306,fork TCP:127.0.0.1:3306
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl daemon-reload
systemctl enable db-port-proxy.service

# Restart the backend services
systemctl restart baic-admin
systemctl restart baic-web

echo "Proxy service created and started. Backend services restarted."
echo "You can check the status of the services with:"
echo "  systemctl status db-port-proxy"
echo "  systemctl status baic-admin"
echo "  systemctl status baic-web"
