# Stage 1: Build stage
FROM debian:bullseye-slim AS plugin-builder

# Install required tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl unzip ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Variables
ARG RANGER_TRINO_VERSION=476
ENV PLUGIN_DIR=/tmp/trino-ranger-${RANGER_TRINO_VERSION}
# Point directly to folder containing JARs after unzip
ENV PLUGIN_LIB_DIR=${PLUGIN_DIR}/trino-ranger-${RANGER_TRINO_VERSION}

# Download and extract plugin
RUN set -eux; \
    curl -sSL https://repo1.maven.org/maven2/io/trino/trino-ranger/${RANGER_TRINO_VERSION}/trino-ranger-${RANGER_TRINO_VERSION}.zip -o /tmp/trino-ranger.zip; \
    mkdir -p ${PLUGIN_DIR}; \
    unzip /tmp/trino-ranger.zip -d ${PLUGIN_DIR}; \
    rm /tmp/trino-ranger.zip

# Stage 2: Final image
FROM trinodb/trino:476

# Plugin directory inside Trino
ENV FINAL_PLUGIN_DIR=/usr/lib/trino/plugin/ranger-trino-plugin

# Create plugin directory
RUN mkdir -p ${FINAL_PLUGIN_DIR}

# Copy JARs from build stage
COPY --from=plugin-builder ${PLUGIN_LIB_DIR}/* ${FINAL_PLUGIN_DIR}/

# Copy Trino config (catalogs + etc)
COPY ./trino-ranger/config/etc /etc/trino
COPY ./trino-ranger/config/catalogs /etc/trino/catalog
