#!/bin/bash 

mosquitto_pub -h localhost -t zigbee2mqtt/0x7cb03eaa0a091af3/set -m '{"state": "ON"}'

source env.properties
backup_dir=$BACKUPS_ROOT_DIRECTORY


# now check if the directory for backups exists
# wait until this is true

while true
do
  if [ -d $backup_dir ]; then
    echo "$backup_dir now exists. Festplatte turned on successfully"
    break;
  else
    echo "$backup_dir does not exist yet. Festplatte not yet ready"
    sleep 30;
  fi
done
