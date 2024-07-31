SELECT                             
    schemaname AS schema_name, 
    relname AS table_name,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_table_size
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC,
         pg_relation_size(relid) DESC
LIMIT 10;

