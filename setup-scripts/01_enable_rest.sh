#!/bin/bash
echo "INFO: Running auto REST-enablement for PDBADMIN schema..."

sql -s sys/${ORACLE_PWD}@//${DBHOST}:${DBPORT}/${DBSERVICENAME} as sysdba << EOF
GRANT INHERIT PRIVILEGES ON USER SYS TO ORDS_METADATA;
GRANT INHERIT PRIVILEGES ON USER PDBADMIN TO ORDS_METADATA;

BEGIN
  ORDS.ENABLE_SCHEMA(
      p_enabled             => TRUE,
      p_schema              => 'PDBADMIN',
      p_url_mapping_type    => 'BASE_PATH',
      p_url_mapping_pattern => 'pdbadmin',
      p_auto_rest_auth      => TRUE);
  COMMIT;
END;
/
exit;
EOF

echo "INFO: Auto REST-enablement script complete."
