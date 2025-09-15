# ===============================
# Stage 1: Build Apache Ranger 2.7.0
# ===============================
# Use a base image that includes Maven and the JDK
FROM maven:3.9.3-eclipse-temurin-8 AS ranger-build

# Set working directory
WORKDIR /opt/ranger

# Clone the specific release branch
RUN git clone --branch release-ranger-2.7.0 https://github.com/apache/ranger.git .

# Build Ranger Admin and Trino plugin using the correct profiles
# We use the profiles we identified during our manual build process.
# This ensures that all necessary dependencies are built.
RUN mvn clean package -P'ranger-admin,ranger-trino-plugin' -DskipTests -Drat.skip=true -Denunciate.skip=true

# ===============================
# Stage 2: Create a minimal image with artifacts
# ===============================
# This is a good intermediate step to show the artifacts,
# but it's not the final runnable image
FROM busybox:latest as ranger-artifacts

# Copy the built artifacts. The names might be different based on the build.
# You will need to verify the exact filenames.
COPY --from=ranger-build /opt/ranger/security-admin/target/*.war /opt/ranger/dist/
COPY --from=ranger-build /opt/ranger/plugin-trino/target/*.jar /opt/ranger/dist/

# ===============================
# Stage 3: Create the final runnable Ranger Admin image
# ===============================
# Use a JRE image since we only need to run Java, not compile it
FROM eclipse-temurin:8-jre

# Create ranger directories
WORKDIR /opt/ranger

# Copy the built admin war file and extract it
# Note: This is an example of extracting a WAR file, but the official Dockerfile might use a tarball.
COPY --from=ranger-build /opt/ranger/security-admin/target/security-admin-web-2.7.0.war /opt/ranger/
RUN mkdir /opt/ranger/admin && \
    unzip /opt/ranger/security-admin-web-2.7.0.war -d /opt/ranger/admin && \
    rm /opt/ranger/security-admin-web-2.7.0.war

# Copy a secure entrypoint script to handle configuration at runtime
COPY entrypoint.sh /opt/ranger/admin/entrypoint.sh

# Set up logs & runtime dirs
RUN mkdir -p /var/log/ranger /var/run/ranger && \
    chown -R root:root /opt/ranger/admin /var/log/ranger /var/run/ranger

# Expose Ranger Admin UI port
EXPOSE 6080

# Use the entrypoint script as the command
CMD ["/opt/ranger/admin/entrypoint.sh"]