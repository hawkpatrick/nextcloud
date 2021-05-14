#!/bin/bash

set -e

# Mit occ einen File-Scan durchführen
sudo docker exec -ti --user www-data  nextcloud php occ files:scan patrick

