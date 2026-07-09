#!/bin/bash
set -e

FLAG_FILE="/opt/oracle/oradata/apex_installed.flag"

if [ -f "$FLAG_FILE" ]; then
    echo "APEX is already installed. Skipping installation."
    exit 0
fi

echo "Starting APEX installation..."

# Install APEX
cd /opt/oracle/apex
sqlplus sys/${ORACLE_PWD}@ORCLPDB1 AS SYSDBA @apexins.sql SYSAUX SYSAUX TEMP /i/

# Configure REST
echo "Configuring APEX REST endpoints..."
(
echo ${APEX_PWD:-Oracle1234}
echo ${APEX_PWD:-Oracle1234}
) | sqlplus -s sys/${ORACLE_PWD}@ORCLPDB1 AS SYSDBA @apex_rest_config.sql

# Set Admin Password
echo "Setting APEX ADMIN password..."
(
echo ADMIN
echo admin@example.com
echo ${APEX_PWD:-Oracle1234}
) | sqlplus -s sys/${ORACLE_PWD}@ORCLPDB1 AS SYSDBA @apxchpwd.sql

# Unlock PDBADMIN and set password
echo "Enabling PDBADMIN account..."
sqlplus -s sys/${ORACLE_PWD}@ORCLPDB1 AS SYSDBA <<EOF
ALTER USER PDBADMIN ACCOUNT UNLOCK;
ALTER USER PDBADMIN IDENTIFIED BY "${ORACLE_PWD}";
EOF

echo "APEX Installation Complete."
touch "$FLAG_FILE"
