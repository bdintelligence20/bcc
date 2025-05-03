#!/bin/bash
# Script to run the VM setup script on the VM

# Set variables
VM_NAME="baic-backend-vm"
VM_ZONE="us-central1-a"

# Check if VM exists
echo "Checking if VM ${VM_NAME} exists..."
if gcloud compute instances describe ${VM_NAME} --zone=${VM_ZONE} &>/dev/null; then
  echo "VM ${VM_NAME} exists."
else
  echo "VM ${VM_NAME} does not exist. Creating VM..."
  gcloud compute instances create ${VM_NAME} \
    --zone=${VM_ZONE} \
    --machine-type=e2-standard-2 \
    --boot-disk-size=20GB \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --tags=http-server,https-server
  
  # Wait for VM to be ready
  echo "Waiting for VM to be ready..."
  sleep 60
fi

# Set up SSH for Cloud Build
echo "Setting up SSH..."
mkdir -p ~/.ssh
ssh-keygen -t rsa -f ~/.ssh/google_compute_engine -N "" -q

# Add the SSH key to the VM's metadata
gcloud compute instances add-metadata ${VM_NAME} --zone=${VM_ZONE} --metadata="ssh-keys=cloudbuild:$(cat ~/.ssh/google_compute_engine.pub)"

# Configure SSH to not check host keys
cat > ~/.ssh/config << EOF
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
EOF
chmod 600 ~/.ssh/config

# Wait for SSH key propagation
echo "Waiting for SSH key propagation..."
sleep 30

# Copy the VM setup script to the VM
echo "Copying VM setup script to VM..."
gcloud compute scp vm-setup.sh cloudbuild@${VM_NAME}:~/vm-setup.sh --zone=${VM_ZONE}

# Make the script executable
echo "Making script executable..."
gcloud compute ssh cloudbuild@${VM_NAME} --zone=${VM_ZONE} --command="chmod +x ~/vm-setup.sh"

# Run the VM setup script
echo "Running VM setup script..."
gcloud compute ssh cloudbuild@${VM_NAME} --zone=${VM_ZONE} --command="~/vm-setup.sh"

echo "VM setup completed successfully!"
