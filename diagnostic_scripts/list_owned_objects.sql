########################################
# This sql script lists all objects owned by particular user.
# Very usefull when deleting user and should know his objects...
########################################

SELECT                     
    pg_namespace.nspname AS SchemaName,
    pg_class.relname AS ObjectName, 
    pg_roles.rolname AS ObjectOwner,
    CASE pg_class.relkind
        WHEN 'r' THEN 'TABLE'
        WHEN 'm' THEN 'MATERIALIZED_VIEW'
        WHEN 'i' THEN 'INDEX'
        WHEN 'S' THEN 'SEQUENCE'
        WHEN 'v' THEN 'VIEW'
        WHEN 'c' THEN 'TYPE'
        ELSE pg_class.relkind::text
    END AS ObjectType
FROM pg_class
 JOIN pg_roles  ON pg_roles.oid = pg_class.relowner
 JOIN pg_namespace ON pg_namespace.oid = pg_class.relnamespace
WHERE pg_namespace.nspname NOT IN ('information_schema', 'pg_catalog')
    AND pg_namespace.nspname NOT LIKE 'pg_toast%'
    AND pg_roles.rolname = 'zmizik'  
ORDER BY pg_namespace.nspname, pg_class.relname;


#########################################################
# This is similar, but as a function (rolename as paramater)
#########################################################

CREATE OR REPLACE FUNCTION get_role_objects(role_name TEXT)
RETURNS TABLE (
    schema_name TEXT,
    object_name TEXT,
    object_type TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT n.nspname AS schema_name,
           c.relname AS object_name,
           c.relkind AS object_type
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relowner = role_name::regrole;
END;
$$ LANGUAGE plpgsql;


