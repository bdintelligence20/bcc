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

# Create a network namespace to handle the comma in the port number
echo "Creating network namespace for port redirection..."
ip netns add db_proxy

# Create a virtual ethernet pair
ip link add veth0 type veth peer name veth1

# Move one end to the namespace
ip link set veth1 netns db_proxy

# Configure the interfaces
ip addr add 192.168.100.1/24 dev veth0
ip netns exec db_proxy ip addr add 192.168.100.2/24 dev veth1
ip link set veth0 up
ip netns exec db_proxy ip link set veth1 up
ip netns exec db_proxy ip link set lo up

# Set up NAT
iptables -t nat -A PREROUTING -p tcp --dport 3306 -j DNAT --to-destination 192.168.100.2:3306
iptables -t nat -A POSTROUTING -s 192.168.100.0/24 -j MASQUERADE
echo 1 > /proc/sys/net/ipv4/ip_forward

# Start socat in the namespace to listen on port 3306 and forward to MySQL
ip netns exec db_proxy socat TCP-LISTEN:3306,fork TCP:127.0.0.1:3306 &

# Create a systemd service to ensure the proxy starts on boot
cat > /etc/systemd/system/db-port-comma-proxy.service << EOF
[Unit]
Description=Database Port Comma Proxy Service
After=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c "ip netns add db_proxy || true; \\
                        ip link add veth0 type veth peer name veth1 || true; \\
                        ip link set veth1 netns db_proxy || true; \\
                        ip addr add 192.168.100.1/24 dev veth0 || true; \\
                        ip netns exec db_proxy ip addr add 192.168.100.2/24 dev veth1 || true; \\
                        ip link set veth0 up; \\
                        ip netns exec db_proxy ip link set veth1 up; \\
                        ip netns exec db_proxy ip link set lo up; \\
                        iptables -t nat -A PREROUTING -p tcp --dport 3306 -j DNAT --to-destination 192.168.100.2:3306 || true; \\
                        iptables -t nat -A POSTROUTING -s 192.168.100.0/24 -j MASQUERADE || true; \\
                        echo 1 > /proc/sys/net/ipv4/ip_forward; \\
                        ip netns exec db_proxy socat TCP-LISTEN:3306,fork TCP:127.0.0.1:3306 &"
ExecStop=/bin/bash -c "ip netns del db_proxy || true; \\
                       ip link del veth0 || true; \\
                       iptables -t nat -D PREROUTING -p tcp --dport 3306 -j DNAT --to-destination 192.168.100.2:3306 || true; \\
                       iptables -t nat -D POSTROUTING -s 192.168.100.0/24 -j MASQUERADE || true"

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl daemon-reload
systemctl enable db-port-comma-proxy.service
systemctl start db-port-comma-proxy.service

# Create a simpler solution: modify the hosts file to redirect localhost to 127.0.0.1
echo "Updating hosts file to ensure localhost resolves to 127.0.0.1..."
grep -q "^127.0.0.1.*localhost" /etc/hosts || echo "127.0.0.1 localhost" >> /etc/hosts

# Create a direct socat proxy for the specific port with comma
echo "Creating direct socat proxy for port with comma..."
socat TCP-LISTEN:3306,fork TCP:127.0.0.1:3306 &

# Restart the backend services
echo "Restarting backend services..."
systemctl restart baic-admin
systemctl restart baic-web

echo "Proxy service created and started. Backend services restarted."
echo "You can check the status of the services with:"
echo "  systemctl status db-port-comma-proxy"
echo "  systemctl status baic-admin"
echo "  systemctl status baic-web"
