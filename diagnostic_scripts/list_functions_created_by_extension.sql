###
# This SQL statement lists all functions that were created by some extension in DB
###
SELECT e.extname, ne.nspname AS extschema, p.proname AS funcname
FROM pg_catalog.pg_extension AS e
    INNER JOIN pg_catalog.pg_depend AS d ON (d.refobjid = e.oid)
    INNER JOIN pg_catalog.pg_proc AS p ON (p.oid = d.objid)
    INNER JOIN pg_catalog.pg_namespace AS ne ON (ne.oid = e.extnamespace)
    WHERE extname = 'NAME OF EXTENSION'
ORDER BY funcname;
