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
RUN apt-get update && apt-get install -y git python3 gettext-base

# Set working directory
WORKDIR /opt/ranger

# Clone the repository
RUN git clone --branch release-ranger-2.7.0 https://github.com/apache/ranger.git .

# Copy the template
COPY install.properties.template /opt/ranger/security-admin/scripts/install.properties.template

# ⭐️ CRITICAL FIX: Explicitly export all ARG values before envsubst ⭐️
RUN export DB_HOST=${DB_HOST} && \
    export DB_PORT=${DB_PORT} && \
    export DB_NAME=${DB_NAME} && \
    export DB_USER=${DB_USER} && \
    export DB_PASSWORD=${DB_PASSWORD} && \
    export DB_FLAVOR=${DB_FLAVOR} && \
    export SQL_CONNECTOR_JAR=${SQL_CONNECTOR_JAR} && \
    export RANGER_ADMIN_PASSWORD=${RANGER_ADMIN_PASSWORD} && \
    export KEYADMIN_PASSWORD=${KEYADMIN_PASSWORD} && \
    export RANGER_TAGSYNC_PASSWORD=${RANGER_TAGSYNC_PASSWORD} && \
    export RANGER_USERSYNC_PASSWORD=${RANGER_USERSYNC_PASSWORD} && \
    export AUDIT_STORE=${AUDIT_STORE} && \
    envsubst < /opt/ranger/security-admin/scripts/install.properties.template \
    > /opt/ranger/security-admin/scripts/install.properties

# Remove the template
RUN rm /opt/ranger/security-admin/scripts/install.properties.template 

# ... (The rest of your original Dockerfile follows, but won't be executed)