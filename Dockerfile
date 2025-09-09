# Stage 1: Build stage
# Use a specific, lightweight Debian image for a reproducible build
FROM debian:bullseye-slim AS plugin-builder

# Install curl, unzip, and the necessary certificates
RUN apt-get update && apt-get install -y --no-install-recommends curl unzip ca-certificates

# Define variables
ARG RANGER_TRINO_VERSION=476
ENV PLUGIN_DIR /tmp/trino-ranger-${RANGER_TRINO_VERSION}
# Correct path where JARs are extracted (no nested lib/)
ENV PLUGIN_LIB_DIR ${PLUGIN_DIR}/trino-ranger-${RANGER_TRINO_VERSION}

# Download and extract the Trino Ranger plugin from Maven
RUN set -eux; \
    curl -sSL https://repo1.maven.org/maven2/io/trino/trino-ranger/${RANGER_TRINO_VERSION}/trino-ranger-${RANGER_TRINO_VERSION}.zip -o /tmp/trino-ranger.zip; \
    mkdir -p ${PLUGIN_DIR}; \
    unzip /tmp/trino-ranger.zip -d ${PLUGIN_DIR}; \
    rm /tmp/trino-ranger.zip; \
    echo "Contents of ${PLUGIN_LIB_DIR}:"; ls -l ${PLUGIN_LIB_DIR}

# Stage 2: Final image
# Start with the official Trino image
FROM trinodb/trino:476

# Define variables for the final image
ENV FINAL_PLUGIN_DIR /usr/lib/trino/plugin/ranger-trino-plugin

# Create the plugin directory
RUN mkdir -p ${FINAL_PLUGIN_DIR}

# Copy the JARs from the build stage to the final plugin directory
COPY --from=plugin-builder ${PLUGIN_LIB_DIR}/ ${FINAL_PLUGIN_DIR}/

# Copy the configuration files from the local directories
COPY ./trino-ranger/config/etc /etc/trino
COPY ./trino-ranger/config/catalogs /etc/trino/catalog
