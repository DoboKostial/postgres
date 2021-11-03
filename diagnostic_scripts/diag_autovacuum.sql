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
