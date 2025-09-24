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
RUN apt-get update && apt-get install -y unzip lsb-release bc netcat-traditional python3 && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /opt/ranger

# Copy the admin distribution archive.
COPY --from=ranger-build /opt/ranger/target/ranger-2.7.0-admin.tar.gz /opt/ranger/

# Extract the distribution archive.
RUN mkdir -p /opt/ranger/admin && \
    tar -xzvf /opt/ranger/ranger-2.7.0-admin.tar.gz -C /opt/ranger/admin --strip-components=1 && \
    rm /opt/ranger/ranger-2.7.0-admin.tar.gz

COPY --from=ranger-build /opt/ranger/security-admin/scripts/db_setup.py /opt/ranger/db_setup.py

# Create the missing lib directory
RUN mkdir -p /opt/ranger/admin/lib

# --- Place the new COPY command here ---
# Copy the PostgreSQL JDBC driver into the lib directory
COPY lib/postgresql-42.7.8.jar /opt/ranger/admin/lib/postgresql-42.7.8.jar

    # This is the line that is missing from your Dockerfile
# It copies your local, customized install.properties file into the image.
COPY install.properties /opt/ranger/admin/install.properties

# Copy the Trino plugin JAR from the build stage to the correct location.
COPY --from=ranger-build /opt/ranger/plugin-trino/target/ranger-trino-plugin-2.7.0.jar /opt/ranger/admin/contrib/

# Patch the setup.sh script to use the correct path. This is the fix.
RUN sed -i 's|${RANGER_ADMIN_CONF:-$PWD}/install.properties|/opt/ranger/admin/install.properties|g' /opt/ranger/admin/setup.sh

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