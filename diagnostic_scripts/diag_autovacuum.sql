##
#this lists all tables according dead tuples and appropriate info (when last autovacuum etc...)
##
SELECT relname  AS "table_name", 
       Extract (epoch FROM CURRENT_TIMESTAMP - last_autovacuum) AS since_last_autovac, 
       autovacuum_count,
       n_tup_ins, 
       n_tup_upd, 
       n_tup_del, 
       n_live_tup, 
       n_dead_tup 
FROM   pg_stat_all_tables 
WHERE  schemaname = 'public'
ORDER  BY n_dead_tup DESC; 

##
# this lists all custom autovacuum (=not cluster wide) parameters defined for table autovacuum
##
SELECT
    relname AS table_name,
    option_name,
    option_value
FROM
    pg_class c
    LEFT JOIN LATERAL pg_options_to_table(c.reloptions) opt ON true
WHERE
    relname = 'NAZEV_TABULKY';
