# Dockerfile (Modified for Debug)
ARG DB_HOST
ARG DB_PORT
ARG DB_NAME
ARG DB_USER
ARG DB_PASSWORD
ARG DB_FLAVOR
ARG SQL_CONNECTOR_JAR
ARG RANGER_ADMIN_PASSWORD
ARG KEYADMIN_PASSWORD
ARG RANGER_TAGSYNC_PASSWORD
ARG RANGER_USERSYNC_PASSWORD
ARG AUDIT_STORE
# ===============================
# Stage 1: Build Apache Ranger 2.7.0
# ===============================
FROM maven:3.9.3-eclipse-temurin-8 AS ranger-build

# Install git and python3.
# Install required dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    python3 \
    gettext-base \
    # Unzip is often needed for Maven packages
    unzip \
    # Cleanup to reduce layer size
    && rm -rf /var/lib/apt/lists/*

ENV DB_HOST=${DB_HOST} \
    DB_PORT=${DB_PORT} \
    DB_NAME=${DB_NAME} \
    DB_USER=${DB_USER} \
    DB_PASSWORD=${DB_PASSWORD} \
    DB_FLAVOR=${DB_FLAVOR} \
    SQL_CONNECTOR_JAR=${SQL_CONNECTOR_JAR} \
    RANGER_ADMIN_PASSWORD=${RANGER_ADMIN_PASSWORD} \
    KEYADMIN_PASSWORD=${KEYADMIN_PASSWORD} \
    RANGER_TAGSYNC_PASSWORD=${RANGER_TAGSYNC_PASSWORD} \
    RANGER_USERSYNC_PASSWORD=${RANGER_USERSYNC_PASSWORD} \
    AUDIT_STORE=${AUDIT_STORE}

# Set working directory
WORKDIR /opt/ranger

# Clone the repository
RUN git clone --branch release-ranger-2.7.0 https://github.com/apache/ranger.git .

# Copy the template
COPY install.properties.template /opt/ranger/security-admin/scripts/install.properties.template

# CRITICAL STEP 2: Generate install.properties using ENV variables
RUN envsubst < /opt/ranger/security-admin/scripts/install.properties.template > /opt/ranger/security-admin/scripts/install.properties

# Cleanup template (optional, but good practice)
RUN rm /opt/ranger/security-admin/scripts/install.properties.template

RUN cat /opt/ranger/security-admin/scripts/install.properties
# ... (The rest of your original Dockerfile follows, but won't be executed)