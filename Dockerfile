FROM amazoncorretto:21 AS builder
WORKDIR /app

# Install required tools
RUN yum install -y tar gzip

COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN chmod +x mvnw && ./mvnw dependency:go-offline

COPY src ./src
RUN ./mvnw package -DskipTests

FROM amazoncorretto:21
WORKDIR /app

# Install required tools and create user
RUN yum install -y shadow-utils && \
    groupadd -r spring && \
    useradd -r -g spring spring && \
    mkdir -p /app/data && \
    chown -R spring:spring /app/data && \
    yum remove -y shadow-utils && \
    yum clean all

COPY --from=builder /app/target/*.jar app.jar
USER spring:spring

ENTRYPOINT ["java", "-jar", "app.jar"] 