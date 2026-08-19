FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -q dependency:go-offline   
COPY src ./src
RUN mvn -q clean package


FROM eclipse-temurin:21-jre-alpine AS Runner
WORKDIR /app
COPY --from=build /app/target/my-app-*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]