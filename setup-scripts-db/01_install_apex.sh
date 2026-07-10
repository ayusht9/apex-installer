#!/bin/bash
set -e

FLAG_FILE="/opt/oracle/oradata/apex_installed.flag"

if [ -f "$FLAG_FILE" ]; then
    echo "APEX is already installed. Skipping installation."
    exit 0
fi

echo "Starting APEX installation..."

cd /opt/oracle/apex
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
    sqlplus -s sys/${ORACLE_PWD}@ORCLPDB1 AS SYSDBA <<EOF
@/opt/oracle/apex/core/scripts/set_appun.sql
alter session set current_schema = &APPUN;
begin
    wwv_flow_instance_admin.create_or_update_admin_user (
        p_username => 'ADMIN',
        p_email    => 'admin@example.com',
        p_password => '${APEX_PWD:-Secret_Pwd_123}' );
    commit;
end;
/
EOF
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

# Unlock APEX users for ORDS
if [ ! -f "/opt/oracle/oradata/apex_users_unlocked.flag" ]; then
    echo "Unlocking APEX accounts for ORDS..."
    sqlplus -s sys/${ORACLE_PWD}@ORCLPDB1 AS SYSDBA <<EOF
ALTER USER APEX_PUBLIC_USER ACCOUNT UNLOCK;
ALTER USER APEX_REST_PUBLIC_USER ACCOUNT UNLOCK;
ALTER USER APEX_LISTENER ACCOUNT UNLOCK;
EOF
    touch "/opt/oracle/oradata/apex_users_unlocked.flag"
else
    echo "APEX accounts already unlocked. Skipping."
fi

echo "APEX Installation Complete."
touch "$FLAG_FILE"