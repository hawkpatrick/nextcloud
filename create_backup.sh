#!/bin/bash

set -e

source env.properties
backups_root_dir=$BACKUPS_ROOT_DIRECOTRY
nextcloud_data_dir=$NEXTCLOUD_DATA_DIRECTORY

mkdir -p $backups_root_dir
backup_foldername="$backups_root_dir/"$(date +'%Y-%m-%d')
rm -rf $backup_foldername
sudo rsync -Aavx "$nextcloud_data_dir/" "$backup_foldername/"
sudo rsync -avh "$nextcloud_data_dir/" "$backups_root_dir/latest/" --delete

./send_mail.sh 'success'
