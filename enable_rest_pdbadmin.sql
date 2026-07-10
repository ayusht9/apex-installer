GRANT INHERIT PRIVILEGES ON USER SYS TO ORDS_METADATA;
GRANT SELECT ON DBA_REGISTRY TO PDBADMIN;
BEGIN
    ORDS.ENABLE_SCHEMA(
        p_enabled => TRUE,
        p_schema => 'PDBADMIN',
        p_url_mapping_type => 'BASE_PATH',
        p_url_mapping_pattern => 'pdbadmin',
        p_auto_rest_auth => TRUE
    );
    COMMIT;
END;
/
EXIT;
