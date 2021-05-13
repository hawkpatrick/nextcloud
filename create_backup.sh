#!/bin/bash

set -e

mkdir -p backups
backup_foldername='backups/data_backup_'$(date +'%Y-%m-%d')
rm -r $backup_foldername
rsync -Aavx data/ "$backup_foldername/"
rsync -avh data/ "backups/data_backup_latest/" --delete

./send_mail.sh 'success'
