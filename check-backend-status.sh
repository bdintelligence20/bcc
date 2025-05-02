#!/bin/bash

# This script checks the status of the backend VM and database

echo "Checking backend VM status..."

# Check if the VM is running
gcloud compute instances describe baic-backend-vm --zone=us-central1-a --format="value(status)"

# Check if the database is running
echo "Checking database status..."
gcloud sql instances describe baic-mysql --format="value(state)"

# Check if the backend services are running
echo "Checking backend services status..."
echo "You'll need to SSH into the VM and run the following commands:"
echo "sudo systemctl status baic-admin"
echo "sudo systemctl status baic-web"

# Check the backend logs
echo "Checking backend logs..."
echo "You'll need to SSH into the VM and run the following commands:"
echo "sudo tail -n 50 /opt/baic/logs/admin.log"
echo "sudo tail -n 50 /opt/baic/logs/web.log"

# SSH into the VM
echo "To SSH into the VM, run the following command:"
echo "gcloud compute ssh baic-backend-vm --zone=us-central1-a"

echo "Done!"
