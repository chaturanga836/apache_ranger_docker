# ===============================
# Stage 1: Build Apache Ranger 2.7.0
# ===============================
FROM maven:3.9.3-eclipse-temurin-8 AS ranger-build

# Install git for cloning the repository
RUN apt-get update && apt-get install -y git

# Set working directory
WORKDIR /opt/ranger

# Clone the specific release branch
RUN git clone --branch release-ranger-2.7.0 https://github.com/apache/ranger.git .

# Build all Ranger modules and install them to the local repository
RUN mvn clean install -DskipTests -Drat.skip=true -Denunciate.skip=true

# ===============================
# Stage 2: Create a minimal image with artifacts
# ===============================
FROM eclipse-temurin:8-jre

# Install unzip, lsb-release, and bc packages, which are required by the setup script
RUN apt-get update && apt-get install -y unzip python3 lsb-release bc && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /opt/ranger

# Copy the entire security-admin distribution archive from the build stage
COPY --from=ranger-build /opt/ranger/security-admin/target/ranger-2.7.0-admin.tar.gz /opt/ranger/

# Extract the distribution archive and move its contents to the admin directory
RUN mkdir -p /opt/ranger/admin && \
    tar -xzvf /opt/ranger/ranger-2.7.0-admin.tar.gz -C /opt/ranger/admin --strip-components=1 && \
    rm /opt/ranger/ranger-2.7.0-admin.tar.gz

# Copy the entrypoint script
COPY entrypoint.sh /opt/ranger/admin/entrypoint.sh

# Set executable permissions on the entrypoint script
RUN chmod +x /opt/ranger/admin/entrypoint.sh

# Set up logs & runtime dirs
RUN mkdir -p /var/log/ranger /var/run/ranger && \
    chown -R root:root /opt/ranger/admin /var/log/ranger /var/run/ranger

# Expose Ranger Admin UI port
EXPOSE 6080

# Use the entrypoint script as the command
CMD ["/opt/ranger/admin/entrypoint.sh"]