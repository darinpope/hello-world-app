FROM docker.io/eclipse-temurin:17.0.4.1_1-alpine as build
LABEL org.opencontainers.image.source https://github.com/darinpope/hello-world-app

WORKDIR /app

COPY .mvn .mvn
COPY mvnw pom.xml ./
COPY src src
RUN ./mvnw package

FROM docker.io/eclipse-temurin:17.0.4.1_1-alpine
COPY --from=build /app/target/demo-0.0.1-SNAPSHOT.jar /app/
ENTRYPOINT ["java","-jar","/app/demo-0.0.1-SNAPSHOT.jar"]