#!/bin/bash
set -e

echo "Generating install.properties from environment variables..."

# Define LOGFILE and other variables to fix ambiguous redirect errors
export RANGER_ADMIN_HOME="/opt/ranger/admin"
export LOGFILE="/var/log/ranger/setup.log"

# Create install.properties file
echo "db_flavor=POSTGRES" > /opt/ranger/install.properties
echo "db_host=${DB_HOST}" >> /opt/ranger/install.properties
echo "db_port=${DB_PORT}" >> /opt/ranger/install.properties
echo "db_name=${DB_NAME}" >> /opt/ranger/install.properties
echo "db_user=${DB_USER}" >> /opt/ranger/install.properties
echo "db_password=${DB_PASSWORD}" >> /opt/ranger/install.properties
echo "audit_store=${AUDIT_STORE}" >> /opt/ranger/install.properties
echo "rangerAdmin_password=${RANGER_ADMIN_PASSWORD}" >> /opt/ranger/install.properties

# Run the setup script to initialize the database
echo "Running setup.sh script..."
/opt/ranger/admin/setup.sh

# Start the Ranger Admin service
echo "Starting Ranger Admin service..."
exec /opt/ranger/admin/ranger-admin-services.sh start