#!/bin/bash

set -e
sudo mkdir -p /media/pi/MyBook/nextcloud_data/patrick/files/Golsa
sudo rsync -avh /media/pi/MyBook/media/Golsa/ /media/pi/MyBook/nextcloud_data/patrick/files/Golsa/

sudo /home/pi/workspace/nextcloud/occ_file_scan.sh
