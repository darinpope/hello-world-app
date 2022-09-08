FROM docker.io/eclipse-temurin:17.0.4.1_1-jre-jammy
LABEL org.opencontainers.image.source https://github.com/darinpope/hello-world-app

WORKDIR /app

COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN ./mvnw dependency:go-offline

COPY src ./src

CMD ["./mvnw", "spring-boot:run"]