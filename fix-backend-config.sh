#!/bin/bash

# This script fixes the database configuration for the backend services and restarts them

# Create temporary directory for extracting and modifying configuration
mkdir -p /tmp/baic-fix

# Stop the running services
echo "Stopping running services..."
sudo systemctl stop ruoyi-admin.service || true
sudo systemctl stop ruoyi-web.service || true
sudo pkill -f ruoyi-admin.jar || true
sudo pkill -f ruoyi-web.jar || true

# Create updated application-prod.yml for ruoyi-admin
echo "Creating updated configuration files..."
cat > /tmp/baic-fix/application-prod-admin.yml << 'EOF'
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
EOF

# Create updated application-prod.yml for ruoyi-web
cat > /tmp/baic-fix/application-prod-web.yml << 'EOF'
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
EOF

# Create systemd service files
cat > /tmp/baic-fix/ruoyi-admin.service << 'EOF'
[Unit]
Description=BAIC Admin Backend Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/baic
ExecStart=/usr/bin/java -Xms1024m -Xmx2048m -jar /opt/baic/ruoyi-admin.jar --spring.profiles.active=prod --spring.config.additional-location=file:/opt/baic/application-prod-admin.yml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

cat > /tmp/baic-fix/ruoyi-web.service << 'EOF'
[Unit]
Description=BAIC Web Backend Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/baic
ExecStart=/usr/bin/java -Xms1024m -Xmx2048m -jar /opt/baic/ruoyi-web.jar --spring.profiles.active=prod --spring.config.additional-location=file:/opt/baic/application-prod-web.yml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Copy configuration files to the correct location
echo "Copying configuration files..."
sudo cp /tmp/baic-fix/application-prod-admin.yml /opt/baic/
sudo cp /tmp/baic-fix/application-prod-web.yml /opt/baic/
sudo cp /tmp/baic-fix/ruoyi-admin.service /etc/systemd/system/
sudo cp /tmp/baic-fix/ruoyi-web.service /etc/systemd/system/

# Reload systemd and start services
echo "Starting services..."
sudo systemctl daemon-reload
sudo systemctl enable ruoyi-admin.service
sudo systemctl enable ruoyi-web.service
sudo systemctl start ruoyi-admin.service
sudo systemctl start ruoyi-web.service

# Wait for services to start
echo "Waiting for services to start..."
sleep 10

# Check if services are running
echo "Checking service status..."
sudo systemctl status ruoyi-admin.service
sudo systemctl status ruoyi-web.service

# Clean up
echo "Cleaning up..."
rm -rf /tmp/baic-fix

echo "Done! Backend services should now be running with the correct database configuration."
