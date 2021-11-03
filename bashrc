# .bashrc


# postgres commands
alias postgres_reload_conf='psql -U postgres -c "SELECT pg_reload_conf();"'
alias postgres_version='psql -U postgres -c "SELECT version()";'
alias postgres_started='psql -U postgres -c "SELECT pg_postmaster_start_time();"'
alias postgres_settings='psql -U postgres -c "TABLE pg_file_settings;"'
alias postgres_data_dir='psql -U postgres -c "SHOW data_directory";'

alias postgres_db_size='psql -U postgres -c "SELECT database_name, pg_size_pretty(size) FROM (SELECT pg_database.datname AS "database_name", pg_database_size(pg_database.datname) AS size FROM pg_database ORDER BY size DESC) AS ordered;"'

alias postgres_conn='psql -U postgres -c "SELECT Count(*) FROM  pg_stat_activity;"'

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi
