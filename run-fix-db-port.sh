#!/bin/bash
# Script to run the database port fix on the VM

# Exit on any error
set -e

# Make the fix script executable
chmod +x fix-db-port-simple.sh

# Set VM details
VM_NAME="baic-backend-vm"
VM_ZONE="us-central1-a"

echo "Setting up SSH..."
mkdir -p ~/.ssh
ssh-keygen -t rsa -f ~/.ssh/google_compute_engine -N "" -q || true

echo "Adding SSH key to VM metadata..."
gcloud compute instances add-metadata ${VM_NAME} --zone=${VM_ZONE} --metadata="ssh-keys=cloudbuild:$(cat ~/.ssh/google_compute_engine.pub)"

echo "Configuring SSH..."
cat > ~/.ssh/config << EOF
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
EOF
chmod 600 ~/.ssh/config

echo "Waiting for SSH key propagation..."
sleep 30

echo "Copying fix script to VM..."
gcloud compute scp fix-db-port-simple.sh cloudbuild@${VM_NAME}:/tmp/ --zone=${VM_ZONE}

echo "Running fix script on VM..."
gcloud compute ssh cloudbuild@${VM_NAME} --zone=${VM_ZONE} --command="chmod +x /tmp/fix-db-port-simple.sh && sudo /tmp/fix-db-port-simple.sh"

echo "Database port fix completed successfully!"
