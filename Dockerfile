# Dockerfile (Modified for Debug)

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

COPY install.properties /opt/ranger/security-admin/scripts/install.properties
# ⭐️ ADD A DEBUG STAGE MARKER AND STOP ⭐️
# This tells Docker to stop the build here.
FROM ranger-build AS repo-cloned-stage
CMD ["/bin/bash"] 

# ... (The rest of your original Dockerfile follows, but won't be executed)