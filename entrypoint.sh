#!/bin/bash
set -e

# Wait for the database service to be ready
echo "Waiting for PostgreSQL database to be ready..."
until nc -z "$DB_HOST" "$DB_PORT"; do
  echo "Database is not ready yet. Waiting..."
  sleep 1
done
echo "Database is ready. Proceeding with setup."

# Correct log file path
export LOGFILE="/var/log/ranger/setup.log"

# echo "Generating install.properties from environment variables..."

# # Generate the file with correct path
# echo "db_flavor=${DB_FLAVOR}" > /opt/ranger/admin/install.properties
# echo "db_host=${DB_HOST}" >> /opt/ranger/admin/install.properties
# echo "db_port=${DB_PORT}" >> /opt/ranger/admin/install.properties
# echo "db_name=${DB_NAME}" >> /opt/ranger/admin/install.properties
# echo "db_user=${DB_USER}" >> /opt/ranger/admin/install.properties
# echo "db_password=${DB_PASSWORD}" >> /opt/ranger/admin/install.properties
# echo "audit_store=${AUDIT_STORE}" >> /opt/ranger/admin/install.properties
# echo "rangerAdmin_password=${RANGER_ADMIN_PASSWORD}" >> /opt/ranger/admin/install.properties
# echo "JAVA_VERSION_REQUIRED=11" >> /opt/ranger/admin/install.properties

# Substitute credential variables
sed -i "s|^rangerAdmin_password=.*|rangerAdmin_password=${RANGER_ADMIN_PASSWORD}|" /opt/ranger/admin/install.properties
sed -i "s|^keyadmin_password=.*|keyadmin_password=${KEYADMIN_PASSWORD}|" /opt/ranger/admin/install.properties
sed -i "s|^rangerTagsync_password=.*|rangerTagsync_password=${RANGER_TAGSYNC_PASSWORD}|" /opt/ranger/admin/install.properties
sed -i "s|^rangerUsersync_password=.*|rangerUsersync_password=${RANGER_USERSYNC_PASSWORD}|" /opt/ranger/admin/install.properties
sed -i "s|^db_user=.*|db_user=${DB_USER}|" /opt/ranger/admin/install.properties
sed -i "s|^db_password=.*|db_password=${DB_PASSWORD}|" /opt/ranger/admin/install.properties
sed -i "s|^db_name=.*|db_name=${DB_NAME}|" /opt/ranger/admin/install.properties
sed -i "s|^db_flavor=.*|db_flavor=${DB_FLAVOR}|" /opt/ranger/admin/install.properties
sed -i "s|^audit_store=.*|audit_store=${AUDIT_STORE}|" /opt/ranger/admin/install.properties
sed -i "s|^SQL_CONNECTOR_JAR=.*|SQL_CONNECTOR_JAR=${SQL_CONNECTOR_JAR}|" /opt/ranger/admin/install.properties

# Run the setup script to initialize the database
echo "Running setup.sh script..."
/opt/ranger/admin/setup.sh

# Start the Ranger Admin service
echo "Starting Ranger Admin service..."
exec /opt/ranger/admin/ranger-admin-services.sh start