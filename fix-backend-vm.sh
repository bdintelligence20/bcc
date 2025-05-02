#!/bin/bash

# This script fixes the backend VM configuration

echo "Fixing backend VM configuration..."

# SSH into the VM and run the following commands
cat << 'EOF' > fix-backend-commands.sh
#!/bin/bash

# Check if the services are running
echo "Checking if services are running..."
sudo systemctl status baic-admin
sudo systemctl status baic-web

# Check the backend logs
echo "Checking backend logs..."
sudo tail -n 50 /opt/baic/logs/admin.log
sudo tail -n 50 /opt/baic/logs/web.log

# Check if the database is accessible
echo "Checking if database is accessible..."
mysql -h 34.69.17.6 -u ruoyi -pStellies21!@ -e "SHOW DATABASES;"

# Fix the application-prod.yml files
echo "Fixing application-prod.yml files..."

# Fix the admin application-prod.yml
sudo cat > /opt/baic/admin/application-prod.yml << 'EOL'
# Spring configuration
spring:
  # Database configuration
  datasource:
    type: com.alibaba.druid.pool.DruidDataSource
    driverClassName: com.mysql.cj.jdbc.Driver
    druid:
      # Master database
      master:
        url: jdbc:mysql://34.69.17.6:3306/ruoyi?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=false&serverTimezone=GMT%2B8
        username: ruoyi
        password: Stellies21!@
      # Slave database
      slave:
        # Whether to enable slave database
        enabled: false
      # Initial connection pool size
      initialSize: 5
      # Minimum connection pool size
      minIdle: 10
      # Maximum connection pool size
      maxActive: 20
      # Configure the time to wait for a connection to be obtained
      maxWait: 60000
      # Configure the interval for detecting idle connections that need to be closed
      timeBetweenEvictionRunsMillis: 60000
      # Configure the minimum lifetime of a connection in the pool
      minEvictableIdleTimeMillis: 300000
      # Configure the maximum lifetime of a connection in the pool
      maxEvictableIdleTimeMillis: 900000
      # Configure detection query for testing if a connection is valid
      validationQuery: SELECT 1 FROM DUAL
      # Enable idle connection testing
      testWhileIdle: true
      # Test when getting a connection
      testOnBorrow: false
      # Test when returning a connection
      testOnReturn: false
      # Enable PSCache
      poolPreparedStatements: true
      # Configure the size of PSCache on each connection
      maxPoolPreparedStatementPerConnectionSize: 20
      # Configure filters
      filters: stat,slf4j
      # Enable connection statistics
      connectionProperties: druid.stat.mergeSql=true;druid.stat.slowSqlMillis=5000
      # Enable web monitoring
      webStatFilter:
        enabled: true
      statViewServlet:
        enabled: true
        # Set white list, allow all access by default
        allow:
        url-pattern: /druid/*
        # Login username and password for the monitoring page
        login-username: admin
        login-password: 123456
      filter:
        stat:
          enabled: true
          # Slow SQL recording
          log-slow-sql: true
          slow-sql-millis: 1000
          merge-sql: true
        wall:
          config:
            multi-statement-allow: true

# Server configuration
server:
  port: 8080
  servlet:
    context-path: /api
EOL

# Fix the web application-prod.yml
sudo cat > /opt/baic/web/application-prod.yml << 'EOL'
# Spring configuration
spring:
  # Database configuration
  datasource:
    type: com.alibaba.druid.pool.DruidDataSource
    driverClassName: com.mysql.cj.jdbc.Driver
    druid:
      # Master database
      master:
        url: jdbc:mysql://34.69.17.6:3306/ruoyi?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=false&serverTimezone=GMT%2B8
        username: ruoyi
        password: Stellies21!@
      # Slave database
      slave:
        # Whether to enable slave database
        enabled: false
      # Initial connection pool size
      initialSize: 5
      # Minimum connection pool size
      minIdle: 10
      # Maximum connection pool size
      maxActive: 20
      # Configure the time to wait for a connection to be obtained
      maxWait: 60000
      # Configure the interval for detecting idle connections that need to be closed
      timeBetweenEvictionRunsMillis: 60000
      # Configure the minimum lifetime of a connection in the pool
      minEvictableIdleTimeMillis: 300000
      # Configure the maximum lifetime of a connection in the pool
      maxEvictableIdleTimeMillis: 900000
      # Configure detection query for testing if a connection is valid
      validationQuery: SELECT 1 FROM DUAL
      # Enable idle connection testing
      testWhileIdle: true
      # Test when getting a connection
      testOnBorrow: false
      # Test when returning a connection
      testOnReturn: false
      # Enable PSCache
      poolPreparedStatements: true
      # Configure the size of PSCache on each connection
      maxPoolPreparedStatementPerConnectionSize: 20
      # Configure filters
      filters: stat,slf4j
      # Enable connection statistics
      connectionProperties: druid.stat.mergeSql=true;druid.stat.slowSqlMillis=5000
      # Enable web monitoring
      webStatFilter:
        enabled: true
      statViewServlet:
        enabled: true
        # Set white list, allow all access by default
        allow:
        url-pattern: /druid/*
        # Login username and password for the monitoring page
        login-username: admin
        login-password: 123456
      filter:
        stat:
          enabled: true
          # Slow SQL recording
          log-slow-sql: true
          slow-sql-millis: 1000
          merge-sql: true
        wall:
          config:
            multi-statement-allow: true

# Server configuration
server:
  port: 8080
  servlet:
    context-path: /home-api
EOL

# Restart the services
echo "Restarting services..."
sudo systemctl restart baic-admin
sudo systemctl restart baic-web

# Check if the services are running
echo "Checking if services are running..."
sudo systemctl status baic-admin
sudo systemctl status baic-web

# Check the backend logs
echo "Checking backend logs..."
sudo tail -n 50 /opt/baic/logs/admin.log
sudo tail -n 50 /opt/baic/logs/web.log

echo "Done!"
EOF

# Make the script executable
chmod +x fix-backend-commands.sh

# Copy the script to the VM
gcloud compute scp fix-backend-commands.sh baic-backend-vm:~ --zone=us-central1-a

# SSH into the VM and run the script
gcloud compute ssh baic-backend-vm --zone=us-central1-a --command="bash fix-backend-commands.sh"

echo "Done!"
