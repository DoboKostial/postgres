#!/bin/bash
#Intent: this is cumulative script to make mass backup (pg_basebackup) 
#on machine with multiple instances (clusters) of PostgreSQL
#
#Usage:
# running clean script leads to pg_basebackup of all running PG Clusters
# running with '--dry-run' only shows what would be backed up
# running with '--cluster="ABC"' leads to pg_basebackup of cluster specified
#dobo@dobo.sk

set -e

### === VARIABLES === ###
PG_BIN="where bindir of PG binaries"
BACKUP_BASE_DIR="backup dir for basebackups"
MAIL_TO="mail@domain.xx"
SMTP_SERVER="what smtp server handling emails?"
WANNA_MAIL="No"    # "Yes" or "No" Do you wanna mail to be sent in case of error?
DRY_RUN=false
CLUSTER_ARG=""
BACKUP_RETENTION=7  # Number of days for keeping backups

### === CONDITIONS FOR DRYRUN AND SPECIFIC CLUSTER === ###
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --cluster) CLUSTER_ARG="$2"; shift ;;
        --dry-run) DRY_RUN=true ;;
        *) echo "Nonvalid argument: $1 Use '--cluster=...' or '--dry-run', junge Bursch... " ; exit 1 ;;
    esac
    shift
done

### === LIST OF RUNNING INSTANCES === ###
TMP_INFO="/tmp/pg_clusters.txt"
> "$TMP_INFO"

ps -eo args | grep '[p]ostgres' | grep -e " -D " | while read -r line; do
    for i in $line; do
        if [[ "$prev" == "-D" ]]; then
            echo "${bin%/postgres}:$i" >> "$TMP_INFO"
        fi
        bin="$i"
        prev="$i"
    done
done

if [[ ! -s "$TMP_INFO" ]]; then
    echo "No running PostgreSQL instance found."
    exit 1
fi

### === LOOPING OVER CLUSTERY === ###
while IFS=: read -r BIN_PATH PGDATA; do

    [[ -n "$CLUSTER_ARG" && "$(basename "$PGDATA")" != "$CLUSTER_ARG" ]] && continue

    CLUSTER_NAME=$(basename "$PGDATA")
    BACKUP_DIR="${BACKUP_BASE_DIR}/${CLUSTER_NAME}_basebackup"
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    ARCHIVE_NAME="${CLUSTER_NAME}_basebackup_${TIMESTAMP}.tar.gz"

    echo "Basebackup of cluster: $CLUSTER_NAME"
    echo "Target folder: $BACKUP_DIR"

    mkdir -p "$BACKUP_DIR"

    PORT=$(grep -E "^[[:space:]]*port[[:space:]]*=" "$PGDATA/postgresql.conf" | cut -d= -f2 | cut -d'#' -f1 | tr -d '[:space:]' | cut -c1-5)
    if [[ -z "$PORT" ]]; then
        echo "Did not find port on $CLUSTER_NAME. Skipping."
        continue
    fi

    IS_REPL=$("$PG_BIN/psql" -qAtX -h /tmp -p "$PORT" -U "$(whoami)" -d postgres -c "select pg_is_in_recovery()")

    if [[ "$IS_REPL" != "f" ]]; then
        echo "Cluster $CLUSTER_NAME is in recovery mode. Skipping."
        continue
    fi

    # === MAZÁNÍ STARÝCH ZÁLOH ===
    echo "Cleaning backups older than $BACKUP_RETENTION days in $BACKUP_DIR"
    find "$BACKUP_DIR" -maxdepth 1 -type f -name "*.tar.gz" -mtime +$BACKUP_RETENTION -print -delete
    find "$BACKUP_DIR" -maxdepth 1 -type f -name "backup_manifest" -mtime +$BACKUP_RETENTION -print -delete

    BACKUP_CMD="$PG_BIN/pg_basebackup -h /tmp -p $PORT -U $(whoami) -w -D $BACKUP_DIR -X stream --format=t --gzip --checkpoint=fast"

    if $DRY_RUN; then
        echo "Dry run: $BACKUP_CMD"
        continue
    fi

    echo "Running wild..."
    if ! $BACKUP_CMD; then
        echo "Backup $CLUSTER_NAME failed."
        if [[ "$WANNA_MAIL" == "Yes" ]]; then
            echo "Backup PostgreSQL DB $CLUSTER_NAME na $(hostname) failed." | \
            mailx -s "PostgreSQL backup failed on $(hostname)" -S smtp="$SMTP_SERVER" "$MAIL_TO"
        fi
        continue
    fi

    echo "Backup OK."

    cd "$BACKUP_DIR"
    if [[ -f basebackup.tar.gz ]]; then
        mv basebackup.tar.gz "$ARCHIVE_NAME"
        echo "Archive renamed to $ARCHIVE_NAME"
    fi

done < "$TMP_INFO"

echo "DONE AND SUCCESS. ALL REQUIRED CLUSTERS BACKED UP."
