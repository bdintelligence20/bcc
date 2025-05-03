#!/bin/bash
# Script to run the frontend fix on the VM

# Exit on any error
set -e

# Make the fix script executable
chmod +x fix-frontend-vm.sh

# Set up SSH for Cloud Build
echo "Setting up SSH..."
mkdir -p ~/.ssh
ssh-keygen -t rsa -f ~/.ssh/google_compute_engine -N "" -q || true

# Add the SSH key to the VM's metadata
echo "Adding SSH key to VM metadata..."
gcloud compute instances add-metadata baic-backend-vm --zone=us-central1-a --metadata="ssh-keys=cloudbuild:$(cat ~/.ssh/google_compute_engine.pub)"

# Configure SSH to not check host keys
echo "Configuring SSH..."
cat > ~/.ssh/config << EOF
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
EOF
chmod 600 ~/.ssh/config

# Wait for SSH key propagation
echo "Waiting for SSH key propagation..."
sleep 30

# Copy the fix script to the VM
echo "Copying fix script to VM..."
gcloud compute scp fix-frontend-vm.sh cloudbuild@baic-backend-vm:/tmp/ --zone=us-central1-a

# Execute the fix script on the VM
echo "Executing fix script on VM..."
gcloud compute ssh cloudbuild@baic-backend-vm --zone=us-central1-a --command="chmod +x /tmp/fix-frontend-vm.sh && sudo /tmp/fix-frontend-vm.sh"

echo "Frontend fix completed successfully!"
