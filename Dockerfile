# Stage 1: Build the plugin
FROM debian:bullseye-slim AS plugin-builder

# Install required tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl unzip ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Variables
ARG RANGER_TRINO_VERSION=476
ENV PLUGIN_DIR=/tmp/trino-ranger-${RANGER_TRINO_VERSION}

# Download and extract plugin
RUN curl -sSL https://repo1.maven.org/maven2/io/trino/trino-ranger/${RANGER_TRINO_VERSION}/trino-ranger-${RANGER_TRINO_VERSION}.zip \
    -o /tmp/trino-ranger.zip && \
    mkdir -p ${PLUGIN_DIR} && \
    unzip /tmp/trino-ranger.zip -d ${PLUGIN_DIR} && \
    rm /tmp/trino-ranger.zip

# Stage 2: Final image
FROM trinodb/trino:476

# Trino plugin folder
ENV FINAL_PLUGIN_DIR=/usr/lib/trino/plugin/ranger-trino-plugin

# Create plugin folder
RUN mkdir -p ${FINAL_PLUGIN_DIR}

# Copy only the JARs Trino expects
COPY --from=plugin-builder /tmp/trino-ranger-476/trino-ranger-476/*.jar ${FINAL_PLUGIN_DIR}/

# Copy Trino configuration
COPY ./trino-ranger/config/etc /etc/trino
COPY ./trino-ranger/config/catalogs /etc/trino/catalog
