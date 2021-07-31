#!/bin/bash

WORLD_NAME=$1
JAR_NAME=$2
JAVA_OPTS=$3
MAX_BACKUPS=$4
BACKUP_TIME_MIN=$5
BACKUP_LOGGING=$6

echo "Starting backup process with config max_backups=$MAX_BACKUPS, backup_time_min=$BACKUP_TIME_MIN, backup_logging=$BACKUP_LOGGING"
/scripts/backup.sh "$WORLD_NAME" "$MAX_BACKUPS" "$BACKUP_TIME_MIN" "$BACKUP_LOGGING" &
BACKUP_PROCESS=$!

_term() {
  echo "Shutting down server process"
  while kill -15 "$SERVER_PROCESS"; do
    sleep 0.5
  done
}

trap _term SIGTERM

echo "Starting server with config world=$WORLD_NAME, java_opts='$JAVA_OPTS'"
while true; do cat /tmp/consolepipe; done | java -server ${JAVA_OPTS} -jar /paper/${JAR_NAME} --universe Worlds --world ${WORLD_NAME} nogui &
SERVER_PROCESS=$!

wait "$SERVER_PROCESS"
echo "Stopping backup task"
kill "$BACKUP_PROCESS"
echo "Shutdown complete"
