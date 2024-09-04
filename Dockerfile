# Use Maven image to build the WAR file
FROM maven:3.8.6-openjdk-11 AS builder

# Set the working directory
WORKDIR /app

# Copy the Maven project files to the container
COPY . .

# Run Maven to build the WAR file
RUN mvn clean package

# Use Tomcat to deploy the WAR file
FROM tomcat:9.0.93

# Copy the WAR file from the builder stage to the Tomcat webapps directory
COPY --from=builder /app/target/sparkjava-hello-world-1.0.war /usr/local/tomcat/webapps/

# Expose port 8080 for external access
EXPOSE 8080

# Run Tomcat server
CMD ["catalina.sh", "run"]
