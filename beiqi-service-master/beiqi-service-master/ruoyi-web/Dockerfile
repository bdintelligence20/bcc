FROM openjdk:8-jdk-alpine

WORKDIR /app

COPY target/ruoyi-web.jar app.jar

# Set environment variables
ENV SPRING_PROFILES_ACTIVE=prod
ENV PORT=8080
ENV JAVA_OPTS="-Xms512m -Xmx1024m -Dserver.port=${PORT} -Dspring.profiles.active=prod"

# Expose the port
EXPOSE ${PORT}

# Use a simple startup command with health check options
CMD java ${JAVA_OPTS} -jar app.jar
