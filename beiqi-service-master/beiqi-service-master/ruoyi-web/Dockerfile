FROM openjdk:8-jdk-alpine

WORKDIR /app

COPY target/ruoyi-web.jar app.jar

ENV SPRING_PROFILES_ACTIVE=prod
ENV SERVER_PORT=8080

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]
