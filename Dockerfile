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

# Install required packages, including gettext for envsubst
RUN apt-get update && apt-get install -y unzip lsb-release bc netcat-traditional python3 gettext && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /opt/ranger

# Copy the admin distribution archive.
COPY --from=ranger-build /opt/ranger/target/ranger-2.7.0-admin.tar.gz /opt/ranger/

# Extract the distribution archive.
RUN mkdir -p /opt/ranger/admin && \
    tar -xzvf /opt/ranger/ranger-2.7.0-admin.tar.gz -C /opt/ranger/admin --strip-components=1 && \
    rm /opt/ranger/ranger-2.7.0-admin.tar.gz

COPY --from=ranger-build /opt/ranger/security-admin/scripts/db_setup.py /opt/ranger/db_setup.py

# Copy the PostgreSQL database schema scripts



# Create the missing lib directory
RUN mkdir -p /opt/ranger/admin/lib

# ADD THIS LINE: Create the full directory structure for the PostgreSQL SQL files
RUN mkdir -p /opt/ranger/admin/db/postgres/optimized/current 

# Copy the PostgreSQL JDBC driver into the lib directory
COPY lib/postgresql-42.7.8.jar /opt/ranger/admin/lib/postgresql-42.7.8.jar

# Copy the core schema (goes into the deep 'optimized/current' path)
COPY --from=ranger-build /opt/ranger/security-admin/db/postgres/optimized/current/ranger_core_db_postgres.sql /opt/ranger/admin/db/postgres/optimized/current/

# Copy the audit schema (goes into the parent 'db/postgres' path)
COPY --from=ranger-build /opt/ranger/security-admin/db/postgres/xa_audit_db_postgres.sql /opt/ranger/admin/db/postgres/
# Copy the install.properties template file.
# NOTE: Make sure to rename your local file from install.properties to install.properties.template
COPY install.properties /opt/ranger/admin/install.properties

# Copy the Trino plugin JAR from the build stage to the correct location.
COPY --from=ranger-build /opt/ranger/plugin-trino/target/ranger-trino-plugin-2.7.0.jar /opt/ranger/admin/contrib/

# Patch the setup.sh script to use the correct path for install.properties. (Existing fix)
RUN sed -i 's|${RANGER_ADMIN_CONF:-$PWD}/install.properties|/opt/ranger/admin/install.properties|g' /opt/ranger/admin/setup.sh

# --------------------------------------------------------------------------------------------------
# ⭐️ NEW FIX: Remove the line containing 'ranger-admin-initd' to skip service registration
RUN sed -i '/ranger-admin-initd/d' /opt/ranger/admin/setup.sh
# --------------------------------------------------------------------------------------------------
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