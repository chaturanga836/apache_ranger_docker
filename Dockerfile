# Stage 1: Build stage
# Use a specific, lightweight Debian image for a reproducible build
FROM debian:bullseye-slim AS plugin-builder

# Install curl, unzip, and necessary certificates
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl unzip ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Define variables
ARG RANGER_TRINO_VERSION=476
ENV PLUGIN_DIR=/tmp/trino-ranger-${RANGER_TRINO_VERSION}
# Correct path for extracted ZIP
ENV PLUGIN_LIB_DIR=${PLUGIN_DIR}/trino-ranger-${RANGER_TRINO_VERSION}

# Download and extract the Trino Ranger plugin
RUN set -eux; \
    curl -sSL https://repo1.maven.org/maven2/io/trino/trino-ranger/${RANGER_TRINO_VERSION}/trino-ranger-${RANGER_TRINO_VERSION}.zip -o /tmp/trino-ranger.zip; \
    mkdir -p ${PLUGIN_DIR}; \
    unzip /tmp/trino-ranger.zip -d ${PLUGIN_DIR}; \
    rm /tmp/trino-ranger.zip

# Stage 2: Final image
FROM trinodb/trino:476

# Plugin directory
ENV FINAL_PLUGIN_DIR=/usr/lib/trino/plugin/ranger-trino-plugin

# Create directories
RUN mkdir -p ${FINAL_PLUGIN_DIR}/lib

# Copy all JARs and files from build stage into plugin directory
COPY --from=plugin-builder ${PLUGIN_LIB_DIR}/ ${FINAL_PLUGIN_DIR}/lib/

# Copy configuration files
COPY ./trino-ranger/config/etc /etc/trino
COPY ./trino-ranger/config/catalogs /etc/trino/catalog
