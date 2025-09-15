# ===============================
# Stage 1: Build Apache Ranger 2.7.0
# ===============================
FROM maven:3.9.3-eclipse-temurin-8 AS ranger-build

# Install required tools
RUN apt-get update && apt-get install -y python3 python3-pip git wget && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /opt/ranger

# Clone the specific release branch
RUN git clone --branch release-ranger-2.7.0 https://github.com/apache/ranger.git .

# Build Ranger without running tests
RUN mvn clean package -P 'ranger-admin,ranger-plugins' -DskipTests -Drat.skip=true -Denunciate.skip=true

# ===============================
# Stage 2: Create Ranger Admin image
# ===============================
FROM eclipse-temurin:8-jre

# Create ranger directories
WORKDIR /opt/ranger

# Copy the built admin tarball from the build stage
COPY --from=ranger-build /opt/ranger/ranger-3.0.0-SNAPSHOT-admin.tar.gz /opt/ranger/

# Extract and link
RUN tar -xvzf ranger-3.0.0-SNAPSHOT-admin.tar.gz && \
    ln -s /opt/ranger/ranger-3.0.0-SNAPSHOT-admin /opt/ranger/admin && \
    rm ranger-3.0.0-SNAPSHOT-admin.tar.gz

# Copy default install.properties (customize DB settings inside)
COPY install.properties /opt/ranger/admin/install.properties

# Set up logs & runtime dirs
RUN mkdir -p /var/log/ranger /var/run/ranger && \
    chown -R root:root /opt/ranger/admin /var/log/ranger /var/run/ranger

# Expose Ranger Admin UI port
EXPOSE 6080

# Run Ranger Admin setup script
CMD ["/opt/ranger/admin/setup.sh"]