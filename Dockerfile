# Dockerfile (Modified for Debug)

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


# ------------------------------------------------------------------
# ⭐️ DYNAMIC CONFIGURATION FIX: Substitution inside Dockerfile ⭐️
# ------------------------------------------------------------------

# 1. Copy the template from your local context.
#    It is copied to the location where the final install.properties is expected
#    by the Ranger source code before packaging.
COPY install.properties.template /opt/ranger/security-admin/scripts/install.properties.template

# 2. Perform the variable substitution using envsubst.
#    This reads the template, replaces placeholders like ${DB_HOST} 
#    with the corresponding environment variable values, and saves the final
#    configured file as 'install.properties'.
RUN envsubst < /opt/ranger/security-admin/scripts/install.properties.template > /opt/ranger/security-admin/scripts/install.properties

# 3. Clean up the template (optional)
RUN rm /opt/ranger/security-admin/scripts/install.properties.template 

# ... (The rest of your original Dockerfile follows, but won't be executed)