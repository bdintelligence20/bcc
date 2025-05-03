# Database Port Fix for BAIC Global

## Problem

The backend services (baic-admin and baic-web) are failing to connect to the MySQL database because they are trying to connect to `localhost:3,306` (with a comma in the port number) instead of `localhost:3306` (the correct port).

This issue is not visible in the source code configuration files, which all have the correct port number. It appears to be a runtime issue, possibly due to a bug in the MySQL connector or how the configuration is being processed.

## Solution

We've created several scripts to fix this issue:

1. `fix-db-port-simple.sh`: A simple script that:
   - Updates the hosts file to ensure localhost resolves to 127.0.0.1
   - Creates an application.properties file that overrides the database connection settings
   - Updates the systemd service files to use this properties file
   - Creates a symbolic link for the database
   - Restarts the services

2. `fix-db-port-proxy.sh`: A script that creates a proxy to redirect connections from port 3306 to 3306.

3. `fix-db-port-comma.sh`: A more complex script that uses network namespaces and NAT to handle the comma in the port number.

4. `run-fix-db-port.sh`: A script that runs the fix on the VM from the Cloud Shell.

## How to Use

### Option 1: If you're already logged into the VM

1. Copy the `fix-db-port-simple.sh` script to the VM
2. Make it executable: `chmod +x fix-db-port-simple.sh`
3. Run it with sudo: `sudo ./fix-db-port-simple.sh`

### Option 2: Using Cloud Shell

1. Make the `run-fix-db-port.sh` script executable: `chmod +x run-fix-db-port.sh`
2. Run it: `./run-fix-db-port.sh`

## Verification

After running the fix, you can verify that it worked by:

1. Checking the status of the services:
   ```bash
   sudo systemctl status baic-admin
   sudo systemctl status baic-web
   ```

2. Checking the logs:
   ```bash
   sudo tail -n 50 /opt/baic/logs/admin.log
   sudo tail -n 50 /opt/baic/logs/web.log
   ```

3. Accessing the frontend at:
   ```
   http://YOUR-VM-IP
   ```

## Troubleshooting

If the fix doesn't work, you can try:

1. Restarting the MySQL server:
   ```bash
   sudo systemctl restart mariadb
   ```

2. Restarting the backend services:
   ```bash
   sudo systemctl restart baic-admin
   sudo systemctl restart baic-web
   ```

3. Checking the database connection:
   ```bash
   sudo mysql -u ruoyi -p -e "SHOW DATABASES;"
   ```

4. Checking the firewall rules:
   ```bash
   sudo iptables -L -n
   ```

5. Checking the network connections:
   ```bash
   sudo netstat -tulpn | grep LISTEN
