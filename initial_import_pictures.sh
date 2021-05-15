#!/bin/bash

set -e

sudo rsync -avh /media/pi/MyBook/media/pictures/ /media/pi/MyBook/nextcloud_data/patrick/files/Pictures/

sudo /home/pi/workspace/nextcloud/occ_file_scan.sh
