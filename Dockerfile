# Use a base image with Java
FROM openjdk:21-jdk-slim AS build

# Set the working directory inside the container
WORKDIR /app

# Copy the built JAR file from the target directory to the container
COPY target/MyMavenProject-1.5.jar MyMavenProject.jar

# Production-specific setup (optional)
ARG SPRING_PROFILE=production
ENV SPRING_PROFILES_ACTIVE=${SPRING_PROFILE}

# Run the application
ENTRYPOINT ["java", "-jar", "MyMavenProject.jar"]
