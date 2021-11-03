SELECT relname
       AS
       "tabulka",
       heap_blks_read
       AS heaps_read,
       heap_blks_hit
       AS heaps_hit,
       ( ( heap_blks_hit * 100 ) / NULLIF(( heap_blks_hit + heap_blks_read ), 0)
       ) AS
       ratio
FROM   pg_statio_user_tables
ORDER BY ratio ASC;
