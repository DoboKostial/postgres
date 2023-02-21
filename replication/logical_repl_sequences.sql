#this SQL script shifts sequences numbering up to next number not to collide with previous
#useful after logical replication on slave node

SELECT format('SELECT SETVAL(%L, (SELECT MAX(%I)+1 FROM %I));' , s.relname, a.attname , t.oid::regclass)
FROM pg_class AS t                                                                                      
   JOIN pg_attribute AS a
      ON a.attrelid = t.oid
   JOIN pg_depend AS d
      ON d.refobjid = t.oid
         AND d.refobjsubid = a.attnum
   JOIN pg_class AS s
      ON s.oid = d.objid
WHERE d.classid = 'pg_catalog.pg_class'::regclass
  AND d.refclassid = 'pg_catalog.pg_class'::regclass
  AND d.deptype IN ('i', 'a')
  AND t.relkind IN ('r', 'P')
  AND s.relkind = 'S'\gexec
