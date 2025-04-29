FROM openjdk:8-jdk-alpine

WORKDIR /app

COPY target/ruoyi-web.jar app.jar

# Set environment variables
ENV SPRING_PROFILES_ACTIVE=prod
ENV PORT=8080

# Expose the port
EXPOSE ${PORT}

# Create a startup script
RUN echo '#!/bin/sh' > /app/startup.sh && \
    echo 'echo "Starting application with JAVA_OPTS: ${JAVA_OPTS}"' >> /app/startup.sh && \
    echo 'java ${JAVA_OPTS} -jar app.jar > /app/app.log 2>&1 &' >> /app/startup.sh && \
    echo 'PID=$!' >> /app/startup.sh && \
    echo 'echo "Application started with PID: ${PID}"' >> /app/startup.sh && \
    echo 'tail -f /app/app.log &' >> /app/startup.sh && \
    echo 'wait ${PID}' >> /app/startup.sh && \
    chmod +x /app/startup.sh

# Use the startup script as the entrypoint
CMD ["/app/startup.sh"]
