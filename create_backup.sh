#!/bin/bash

set -e
cd /home/pi/workspace/nextcloud
source env.properties

backups_root_dir=$BACKUPS_ROOT_DIRECOTRY
nextcloud_data_dir=$NEXTCLOUD_DATA_DIRECTORY

if [ -d "$backups_root_dir" ]; then
  echo "Root directory for backups is $backups_root_dir"
else 
  echo "Directory for backups should be $backups_root_dir but it does not exist. Aborting"
  exit 1
fi

backup_foldername="$backups_root_dir/"$(date +'%Y-%m-%d')
sudo rsync -Aavx "$nextcloud_data_dir/patrick/files" "$backup_foldername/"
sudo rsync -avh "$nextcloud_data_dir/patrick/files" "$backups_root_dir/latest/" --delete

./send_mail.sh 'success'
