# ===============================
# Stage 1: Build Apache Ranger 2.7.0
# ===============================
FROM maven:3.9.3-eclipse-temurin-8 AS ranger-build

# Install git and python3.
RUN apt-get update && apt-get install -y git python3

# Set working directory
WORKDIR /opt/ranger

# Clone the repository
RUN git clone --branch release-ranger-2.7.0 https://github.com/apache/ranger.git .

# Use 'mvn clean install' to build the admin tarball and the trino plugin JAR.
RUN mvn clean install -DskipTests -Drat.skip=true -Denunciate.skip=true

# ===============================
# Stage 2: Create a minimal image with artifacts
# ===============================
FROM eclipse-temurin:11-jre

# Install unzip, lsb-release, and bc.
RUN apt-get update && apt-get install -y unzip lsb-release bc && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /opt/ranger

# Copy the admin distribution archive.
COPY --from=ranger-build /opt/ranger/target/ranger-2.7.0-admin.tar.gz /opt/ranger/

# Extract the distribution archive.
RUN mkdir -p /opt/ranger/admin && \
    tar -xzvf /opt/ranger/ranger-2.7.0-admin.tar.gz -C /opt/ranger/admin --strip-components=1 && \
    rm /opt/ranger/ranger-2.7.0-admin.tar.gz

# Copy the Trino plugin JAR from the build stage to the correct location.
COPY --from=ranger-build /opt/ranger/plugin-trino/target/ranger-trino-plugin-2.7.0.jar /opt/ranger/admin/contrib/

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