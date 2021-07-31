#!/bin/bash

WORLD_NAME=$1
MAX_BACKUPS=$2
BACKUP_TIME_MIN=$3
BACKUP_LOGGING=$4
while true
do
  sleep ${BACKUP_TIME_MIN}m
  if [ -d "/backups/$WORLD_NAME" ]; then
    while [ $(ls -1q /backups/${WORLD_NAME} | wc -l) -ge ${MAX_BACKUPS} ]
    do
      OLDEST=$(ls -1t /backups/${WORLD_NAME} | tail -1)
      rm /backups/${WORLD_NAME}/${OLDEST}
    done
  fi
  NOW=$(date +"%s")
  if [ ${BACKUP_LOGGING} = "true" ]; then
    echo "Creating backup for <$WORLD_NAME>: Backup$NOW"
  fi
  7z a /backups/${WORLD_NAME}/Backup${NOW} /paper/Worlds/${WORLD_NAME} /paper/Worlds/${WORLD_NAME}_nether /paper/Worlds/${WORLD_NAME}_the_end -bso0 -bsp0
  if [ ${BACKUP_LOGGING} = "true" ]; then
    echo "Backup finished"
  fi
done
