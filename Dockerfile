
# ===============================
# Stage 1: Build Apache Ranger 2.7.0
# ===============================
FROM ubuntu:22.04 AS ranger-build 
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
# Install git and python3.
# Install required dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-8-jdk \
    maven \
    git \
    python3 \
    gettext-base \
    wget \
    unzip \
    # 🛑 FIX 1: Add missing Linux utilities
    lsb-release \
    bc \
    # Cleanup
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV MAVEN_HOME=/usr/share/maven
ENV PATH=$MAVEN_HOME/bin:$PATH

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

RUN mkdir -p /opt/ranger/admin/lib && \
    wget -O /opt/ranger/admin/lib/postgresql-42.7.8.jar \
    https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.8/postgresql-42.7.8.jar

ENV MAVEN_OPTS="-Xms1024m -Xmx2048m"
# 1. Run the Maven build (This compiles Ranger and requires the config file to exist)
RUN mvn clean package assembly:single -DskipTests -Denunciate.skip=true -P!distro

# 🔑 CRITICAL FIX: Copy the generated config to the root directory 🔑
# The setup.sh script is hardcoded to look for install.properties in the /opt/ranger root.
# RUN cp /opt/ranger/security-admin/scripts/install.properties /opt/ranger/install.properties

# WORKDIR /opt/ranger
# RUN ./security-admin/scripts/setup.sh