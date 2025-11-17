FROM gradle:7.6-jdk17 AS build

WORKDIR /app

COPY build.gradle settings.gradle ./
COPY src ./src

RUN gradle build -x test --no-daemon

FROM openjdk:17-jre-slim

WORKDIR /app

COPY --from=build /app/build/libs/*.jar app.jar

EXPOSE 8081

ENTRYPOINT ["java", "-jar", "app.jar"]

