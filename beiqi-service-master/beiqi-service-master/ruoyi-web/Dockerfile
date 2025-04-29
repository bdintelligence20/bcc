FROM openjdk:8-jdk-alpine

WORKDIR /app

COPY target/ruoyi-web.jar app.jar

ENV SPRING_PROFILES_ACTIVE=prod
ENV PORT=8080
ENV SERVER_PORT=${PORT}

EXPOSE ${PORT}

# Explicitly set server.port to use the PORT environment variable
CMD ["sh", "-c", "java -jar -Dserver.port=${PORT} app.jar"]
