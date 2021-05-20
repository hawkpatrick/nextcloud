#!/bin/bash

set -e
cd /home/pi/workspace/nextcloud

./turn_backup_festplatte_on.sh

source env.properties

backups_root_dir=$BACKUPS_ROOT_DIRECTORY #'/media/pi/Trekstor/nextcloud_backups'
nextcloud_data_dir=$NEXTCLOUD_DATA_DIRECTORY

if [ -d "$backups_root_dir" ]; then
  echo "Root directory for backups is $backups_root_dir"
else 
  echo "Directory for backups should be $backups_root_dir but it does not exist. Aborting"
  exit 1
fi

# Auf trekstor ist nur Platz für maximal 1 Backup 
# daher wird das Backup-Verzeichnis nicht mit Zeitstempl, 
# sondern mit latest benannt.
#backup_foldername="$backups_root_dir/"$(date +'%Y-%m-%d')
backup_foldername="$backups_root_dir/latest"

sudo rsync -Aavx "$nextcloud_data_dir/patrick/files/" "$backup_foldername/"

./send_mail.sh 'success'

./turn_backup_festplatte_off.sh
