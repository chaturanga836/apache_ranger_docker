#!/bin/bash
set -e

echo "Generating install.properties from environment variables..."

# Generate the install.properties file from environment variables
cat <<EOF > /opt/ranger/admin/install.properties
db_flavor=POSTGRES
db_host=${DB_HOST}
db_port=${DB_PORT}
db_name=${DB_NAME}
db_user=${DB_USER}
db_password=${DB_PASSWORD}
audit_store=${AUDIT_STORE}
rangerAdmin_password=${RANGER_ADMIN_PASSWORD}
EOF

# Run the setup script to initialize the database
echo "Running setup.sh script..."
/opt/ranger/admin/setup.sh

# Start the Ranger Admin service
echo "Starting Ranger Admin service..."
# Use the correct startup script. This is typically located in the bin directory.
exec /opt/ranger/admin/ranger-admin-services.sh start