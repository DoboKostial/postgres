########################################
# This sql script lists all objects owned by particular user.oll objects owned by particular user.
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
