#!/bin/bash
set -e

FLAG_FILE="/opt/oracle/oradata/apex_installed.flag"

if [ -f "$FLAG_FILE" ]; then
    echo "APEX is already installed. Skipping installation."
    exit 0
fi

echo "Starting APEX installation..."

# Install APEX
if [ ! -f "/opt/oracle/oradata/apex_core.flag" ]; then
    echo "Installing Core APEX tables (this takes ~15 mins)..."
    cd /opt/oracle/apex
    sqlplus sys/${ORACLE_PWD}@ORCLPDB1 AS SYSDBA @apexins.sql SYSAUX SYSAUX TEMP /i/
    touch "/opt/oracle/oradata/apex_core.flag"
else
    echo "Core APEX tables already installed. Skipping."
fi

# Configure REST
if [ ! -f "/opt/oracle/oradata/apex_rest.flag" ]; then
    echo "Configuring APEX REST endpoints..."
    (
    echo ${APEX_PWD:-Secret_Pwd_123}
    echo ${APEX_PWD:-Secret_Pwd_123}
    ) | sqlplus -s sys/${ORACLE_PWD}@ORCLPDB1 AS SYSDBA @apex_rest_config.sql
    touch "/opt/oracle/oradata/apex_rest.flag"
else
    echo "APEX REST already configured. Skipping."
fi

# Set Admin Password
if [ ! -f "/opt/oracle/oradata/apex_admin.flag" ]; then
    echo "Setting APEX ADMIN password..."
    (
    echo ADMIN
    echo admin@example.com
    echo ${APEX_PWD:-Secret_Pwd_123}
    ) | sqlplus -s sys/${ORACLE_PWD}@ORCLPDB1 AS SYSDBA @apxchpwd.sql
    touch "/opt/oracle/oradata/apex_admin.flag"
else
    echo "APEX ADMIN password already set. Skipping."
fi

# Unlock PDBADMIN and set password
if [ ! -f "/opt/oracle/oradata/apex_pdbadmin.flag" ]; then
    echo "Enabling PDBADMIN account..."
    sqlplus -s sys/${ORACLE_PWD}@ORCLPDB1 AS SYSDBA <<EOF
ALTER USER PDBADMIN ACCOUNT UNLOCK;
ALTER USER PDBADMIN IDENTIFIED BY "${ORACLE_PWD}";
EOF
    touch "/opt/oracle/oradata/apex_pdbadmin.flag"
else
    echo "PDBADMIN account already enabled. Skipping."
fi

echo "APEX Installation Complete."
touch "$FLAG_FILE"