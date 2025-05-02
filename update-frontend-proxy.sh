#!/bin/bash
# Script to update the frontend proxy configuration

set -e  # Exit on any error

# Configuration
VM_NAME="baic-backend-vm"
VM_ZONE="us-central1-a"

echo "Updating frontend proxy configuration..."

# Get the external IP of the backend VM
BACKEND_IP=$(gcloud compute instances describe ${VM_NAME} --zone=${VM_ZONE} --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

if [ -z "$BACKEND_IP" ]; then
  echo "Error: Could not get the external IP of the backend VM."
  exit 1
fi

echo "Backend VM IP: $BACKEND_IP"

# Update the nuxt.config.js file
echo "Updating nuxt.config.js..."
sed -i "s|target: 'http://[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+:8080'|target: 'http://$BACKEND_IP:8080'|g" beiqi-home-master/beiqi-home-master/nuxt.config.js

# Create a script to update the API calls in the frontend
echo "Creating script to update API calls..."
cat > fix-api-calls.sh << EOF
#!/bin/bash
# Script to fix API calls in the frontend

set -e  # Exit on any error

echo "Fixing API calls in the frontend..."

# Find all API call files
API_FILES=\$(find beiqi-home-master/beiqi-home-master/api/apiList -type f -name "*.js")

# Update each file to ensure it uses the correct prefix
for file in \$API_FILES; do
  echo "Updating \$file..."
  # Replace URLs without prefix with /home-api prefix
  sed -i 's|url: "/|url: "/home-api/|g' "\$file"
  # Ensure the URL doesn't have double prefixes
  sed -i 's|url: "/home-api/home-api/|url: "/home-api/|g' "\$file"
done

echo "API calls fixed successfully!"
EOF

# Make the script executable
chmod +x fix-api-calls.sh

# Run the script to fix API calls
echo "Running script to fix API calls..."
./fix-api-calls.sh

echo "Frontend proxy configuration updated successfully!"
