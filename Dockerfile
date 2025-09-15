# ===============================
# Stage 1: Build Apache Ranger 2.7.0
# ===============================
FROM maven:3.9.3-eclipse-temurin-8 AS ranger-build

# Install required tools for the build. Only install python3 and git.
RUN apt-get update && apt-get install -y python3 git wget && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /opt/ranger

# Clone the specific release branch
RUN git clone --branch release-ranger-2.7.0 https://github.com/apache/ranger.git .

# Build Ranger Admin and Trino plugin using the correct profiles
RUN mvn clean package -P'ranger-admin,ranger-trino-plugin' -DskipTests -Drat.skip=true -Denunciate.skip=true

# ===============================
# Stage 2: Create a minimal image with artifacts
# ===============================
FROM busybox:latest as ranger-artifacts

COPY --from=ranger-build /opt/ranger/security-admin/target/*.war /opt/ranger/dist/
COPY --from=ranger-build /opt/ranger/plugin-trino/target/*.jar /opt/ranger/dist/

# ===============================
# Stage 3: Create the final runnable Ranger Admin image
# ===============================
FROM eclipse-temurin:8-jre

# Install the unzip utility in the final image
RUN apt-get update && apt-get install -y unzip && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/ranger

COPY --from=ranger-build /opt/ranger/security-admin/target/security-admin-web-2.7.0.war /opt/ranger/
RUN mkdir /opt/ranger/admin && \
    unzip /opt/ranger/security-admin-web-2.7.0.war -d /opt/ranger/admin && \
    rm /opt/ranger/security-admin-web-2.7.0.war

# Copy a secure entrypoint script to handle configuration at runtime
COPY entrypoint.sh /opt/ranger/admin/entrypoint.sh

# Copy the setup script from the build stage to the final image
COPY --from=ranger-build /opt/ranger/security-admin/scripts/setup.sh /opt/ranger/admin/setup.sh

# Set executable permissions on the entrypoint script
RUN chmod +x /opt/ranger/admin/entrypoint.sh

# Set up logs & runtime dirs
RUN mkdir -p /var/log/ranger /var/run/ranger && \
    chown -R root:root /opt/ranger/admin /var/log/ranger /var/run/ranger

# Expose Ranger Admin UI port
EXPOSE 6080

# Use the entrypoint script as the command
CMD ["/opt/ranger/admin/entrypoint.sh"]