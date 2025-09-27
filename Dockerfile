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

# 2. Use SED to replace each placeholder with the corresponding ARG value
RUN sed -i "s|@@DB_FLAVOR@@|${DB_FLAVOR}|g" /opt/ranger/security-admin/scripts/install.properties
RUN sed -i "s|@@SQL_CONNECTOR_JAR@@|${SQL_CONNECTOR_JAR}|g" /opt/ranger/security-admin/scripts/install.properties

# DB Connection Details (Host, Port, User, Pass)
RUN sed -i "s|@@DB_HOST@@|${DB_HOST}|g" /opt/ranger/security-admin/scripts/install.properties
RUN sed -i "s|@@DB_PORT@@|${DB_PORT}|g" /opt/ranger/security-admin/scripts/install.properties
RUN sed -i "s|@@DB_NAME@@|${DB_NAME}|g" /opt/ranger/security-admin/scripts/install.properties
RUN sed -i "s|@@DB_USER@@|${DB_USER}|g" /opt/ranger/security-admin/scripts/install.properties
RUN sed -i "s|@@DB_PASSWORD@@|${DB_PASSWORD}|g" /opt/ranger/security-admin/scripts/install.properties

# Passwords
RUN sed -i "s|@@RANGER_ADMIN_PASSWORD@@|${RANGER_ADMIN_PASSWORD}|g" /opt/ranger/security-admin/scripts/install.properties
RUN sed -i "s|@@KEYADMIN_PASSWORD@@|${KEYADMIN_PASSWORD}|g" /opt/ranger/security-admin/scripts/install.properties
RUN sed -i "s|@@RANGER_TAGSYNC_PASSWORD@@|${RANGER_TAGSYNC_PASSWORD}|g" /opt/ranger/security-admin/scripts/install.properties
RUN sed -i "s|@@RANGER_USERSYNC_PASSWORD@@|${RANGER_USERSYNC_PASSWORD}|g" /opt/ranger/security-admin/scripts/install.properties

# Audit Store
RUN sed -i "s|@@AUDIT_STORE@@|${AUDIT_STORE}|g" /opt/ranger/security-admin/scripts/install.properties

# ------------------------------------------------------------------

# Remove the template
RUN rm /opt/ranger/security-admin/scripts/install.properties.template 

# ... (The rest of your original Dockerfile follows, but won't be executed)