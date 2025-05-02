#!/bin/bash

# This script updates the configuration files on the VM to use the local database

# Create the configuration files for the admin service
cat > /opt/baic/application-prod-admin.yml << 'EOF'
# Spring configuration
spring:
  # Database configuration
  datasource:
    type: com.alibaba.druid.pool.DruidDataSource
    driverClassName: com.mysql.cj.jdbc.Driver
    druid:
      # Master database
      master:
        url: jdbc:mysql://127.0.0.1:3306/baicintl?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=false&serverTimezone=GMT%2B8
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

# Create the configuration files for the web service
cat > /opt/baic/application-prod-web.yml << 'EOF'
# Spring configuration
spring:
  # Database configuration
  datasource:
    type: com.alibaba.druid.pool.DruidDataSource
    driverClassName: com.mysql.cj.jdbc.Driver
    druid:
      # Master database
      master:
        url: jdbc:mysql://127.0.0.1:3306/baicintl?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=false&serverTimezone=GMT%2B8
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

# Restart the services
systemctl restart baic-admin
systemctl restart baic-web

echo "Configuration files updated and services restarted"
