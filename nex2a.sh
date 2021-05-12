#!/bin/bash

set -e

source secrets.sh

# Start des Nextcloud-Containers
#  * "data" muss nach /var/www/html/data gemountet werden. 
#  * OC_PASS muss gesetzt werden, damit ein User-Passwort per Umgebungsvariable gesetzt werden kann
#  * skeleton wird gemountet, um Standard-Dateien zu überschreiben (wir wollen gar keine)

sudo docker run --name nextcloud -d \
-e SQLITE_DATABASE=sqlite \
-e NEXTCLOUD_ADMIN_USER=admin \
-e NEXTCLOUD_ADMIN_PASSWORD=$ADMIN_PASSWORD \
-e OC_PASS=$PATRICK_PASSWORD \
-p 8080:80 \
-v "$PWD/data":/var/www/html/data \
-v "$PWD/skeleton":/tmp/myskeleton \
nextcloud

echo "Docker container nextcloud created. Now waiting 15 seconds for it to come up"

sleep 15

# Setze das skeletondirectory (enthält Standard-Dateien für neue User) auf das gemountete leere Verzeichnis
sudo docker exec --user www-data nextcloud php occ config:system:set skeletondirectory --value='/tmp/myskeleton'


# User "patrick" in Nextcloud anlegen:

sudo docker exec --user www-data nextcloud php occ user:add --display-name="Patrick" --group="users" --password-from-env patrick


# Die Daten sollen ins nextcloud-Daten-Verzeichnis für User patrick kopiert werden, 
# also unter ./data/patrick/files. Dies ist bei nextcloud vorgegeben. 
sudo mkdir -p ./data/patrick/files

# Annahme: Die zu kopierenden Daten liegen unter /home/pho/Pictures
sudo cp -r /home/pho/Pictures data/patrick/files/Pictures
sudo cp -r /home/pho/Videos data/patrick/files/Videos


# Für den Ordner "data" wird der Owner wie folgt gesetzt: 
# User "www-data" und Gruppe "pho". 
# Dadurch kann der User www-data Vollzugreifen (für nextcloud nötig) und die Gruppe pho ebenfalls. # Letzteres ist nötig, damit man über den Datei-Explorer zugreifen kann, wenn man möchte. 
sudo chown -R www-data:pho data


# Mit occ einen File-Scan durchführen
sudo docker exec -ti --user www-data  nextcloud php occ files:scan patrick

echo "Everything finished. Now login as patrick"
