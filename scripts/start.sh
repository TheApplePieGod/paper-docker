#!/bin/bash

WORLD_NAME=$1
JAR_NAME=$2
JAR_OVERRIDE=$3
JAVA_OPTS=$4
MAX_BACKUPS=$5
BACKUP_TIME_MIN=$6
BACKUP_LOGGING=$7

if [ ${BACKUP_TIME_MIN} = "0" ]; then
  echo "Backups disabled!"
else
  echo "Starting backup process with config max_backups=$MAX_BACKUPS, backup_time_min=$BACKUP_TIME_MIN, backup_logging=$BACKUP_LOGGING"
  /scripts/backup.sh "$WORLD_NAME" "$MAX_BACKUPS" "$BACKUP_TIME_MIN" "$BACKUP_LOGGING" &
  BACKUP_PROCESS=$!
fi

_term() {
  echo "Shutting down server process"
  kill -15 "$SERVER_PROCESS"
  while ps -p "$SERVER_PROCESS" > /dev/null
  do
    sleep 0.5
  done
}

trap _term SIGTERM

echo "Starting server with config world=$WORLD_NAME, java_opts='$JAVA_OPTS'"

if [ "${JAR_OVERRIDE}" = "" ]
then
  tail -n1 -f /tmp/consolepipe | ${JAVA_HOME}/bin/java -server ${JAVA_OPTS} -jar /paper/${JAR_NAME} --universe Worlds --world ${WORLD_NAME} --nogui &
else
  tail -n1 -f /tmp/consolepipe | ${JAVA_HOME}/bin/java -server ${JAVA_OPTS} ${JAR_OVERRIDE} &
fi

SERVER_PROCESS=$!

wait "$SERVER_PROCESS"

if [ ${BACKUP_TIME_MIN} != "0" ]; then
  echo "Stopping backup task"
  kill "$BACKUP_PROCESS"
fi

echo "Shutdown complete"
