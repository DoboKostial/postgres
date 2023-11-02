# quick scripts for pg_stat_statements usage
# tested on Postgresql 13

# 20 most memory consuming queries
SELECT userid::regrole, dbid, query, shared_blks_hit, shared_blks_dirtied, calls
FROM pg_stat_statements
ORDER BY (shared_blks_hit+shared_blks_dirtied) DESC
LIMIT 20;
