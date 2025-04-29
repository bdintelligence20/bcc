FROM openjdk:8-jdk-alpine

WORKDIR /app

COPY target/ruoyi-admin.jar app.jar

# Set environment variables
ENV SPRING_PROFILES_ACTIVE=prod
ENV PORT=8080

# Expose the port
EXPOSE ${PORT}

# Add a startup script to capture logs and use JAVA_OPTS from app.yaml
COPY <<EOF /app/startup.sh
#!/bin/sh
echo "Starting application with JAVA_OPTS: \${JAVA_OPTS}"
java \${JAVA_OPTS} -jar app.jar > /app/app.log 2>&1 &
PID=\$!
echo "Application started with PID: \${PID}"
# Keep the container running and tail the logs
tail -f /app/app.log &
wait \${PID}
EOF

RUN chmod +x /app/startup.sh

# Use the startup script as the entrypoint
CMD ["/app/startup.sh"]
