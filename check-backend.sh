#!/bin/bash

# This script checks if the backend services are running and accessible

echo "Checking if backend services are running..."

# Check if the VM is accessible
echo "Checking VM accessibility..."
ping -c 3 34.42.200.5

# Check if the ports are open
echo "Checking if ports are open..."
nc -zv 34.42.200.5 8080

# Check if the backend services are responding
echo "Checking if backend services are responding..."
curl -I http://34.42.200.5:8080/api/
curl -I http://34.42.200.5:8080/home-api/

# Check if the database is accessible
echo "Checking if database is accessible..."
echo "You'll need to SSH into the VM and run the following commands:"
echo "mysql -h 34.69.17.6 -u ruoyi -p"
echo "Enter the password: Stellies21!@"
echo "Then run: SHOW DATABASES;"

# Check the backend logs
echo "Checking backend logs..."
echo "You'll need to SSH into the VM and run the following commands:"
echo "sudo tail -n 50 /opt/baic/logs/admin.log"
echo "sudo tail -n 50 /opt/baic/logs/web.log"

# Check if the services are running
echo "Checking if services are running..."
echo "You'll need to SSH into the VM and run the following commands:"
echo "sudo systemctl status baic-admin"
echo "sudo systemctl status baic-web"

echo "Done!"
