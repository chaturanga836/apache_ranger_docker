# ===============================
# Stage 3: Create the final runnable Ranger Admin image
# ===============================
FROM eclipse-temurin:8-jre

# Install unzip, lsb-release, and bc to satisfy setup.sh dependencies
RUN apt-get update && apt-get install -y unzip lsb-release bc && rm -rf /var/lib/apt/lists/*

# Create ranger directories
WORKDIR /opt/ranger

# Copy the built admin war file and extract it
COPY --from=ranger-build /opt/ranger/security-admin/target/security-admin-web-2.7.0.war /opt/ranger/
RUN mkdir /opt/ranger/admin && \
    unzip /opt/ranger/security-admin-web-2.7.0.war -d /opt/ranger/admin && \
    rm /opt/ranger/security-admin-web-2.7.0.war

# Copy the entrypoint script
COPY entrypoint.sh /opt/ranger/admin/entrypoint.sh

# Copy the setup script from the build stage to the final image
COPY --from=ranger-build /opt/ranger/security-admin/scripts/setup.sh /opt/ranger/admin/setup.sh

# Copy the version file, which is required by the setup script
COPY --from=ranger-build /opt/ranger/version /opt/ranger/version

# Set executable permissions on the entrypoint and setup scripts
RUN chmod +x /opt/ranger/admin/entrypoint.sh /opt/ranger/admin/setup.sh

# Set up logs & runtime dirs
RUN mkdir -p /var/log/ranger /var/run/ranger && \
    chown -R root:root /opt/ranger/admin /var/log/ranger /var/run/ranger

# Expose Ranger Admin UI port
EXPOSE 6080

# Use the entrypoint script as the command
CMD ["/opt/ranger/admin/entrypoint.sh"]