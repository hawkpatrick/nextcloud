#!/bin/bash

set -e

source secrets.sh
source env.properties

data_directory=$NEXTCLOUD_DATA_DIRECTORY
mkdir "$data_directory" || echo "$data_directory was not created. Probably already exists"

# Für den Ordner "$data_directory" wird der Owner wie folgt gesetzt:
# User "www-data" und Gruppe "pho".
# Dadurch kann der User www-data Vollzugreifen (für nextcloud nötig) und die Gruppe pho ebenfalls. 
# Letzteres ist nötig, damit man über den Datei-Explorer zugreifen kann, wenn man möchte.
#sudo groupadd -f pho
#sudo chown -R www-data:pho "$data_directory"

# Start des Nextcloud-Containers
#  * "$data_directory" muss nach /var/www/html/data gemountet werden. 
#  * OC_PASS muss gesetzt werden, damit ein User-Passwort per Umgebungsvariable gesetzt werden kann
#  * skeleton wird gemountet, um Standard-Dateien zu überschreiben (wir wollen gar keine)

sudo docker run --name nextcloud -d \
-e SQLITE_DATABASE=sqlite \
-e NEXTCLOUD_ADMIN_USER=admin \
-e NEXTCLOUD_ADMIN_PASSWORD=$ADMIN_PASSWORD \
-e OC_PASS=$PATRICK_PASSWORD \
-p 8080:80 \
-v "$data_directory":/var/www/html/data \
-v "$PWD/skeleton":/tmp/myskeleton \
nextcloud

echo "Docker container nextcloud created. Now waiting for it to come up. Therfore we will curl every 5 seconds on login page and check if status code is 200"

startup_status_code="0"
while [[ "200" != $startup_status_code ]]; do
  sleep 5
  startup_status_code=$(curl --max-time 2 --write-out %{http_code} --silent --output /dev/null localhost:8080/login) || echo "curl failed. Waiting for 5 seconds and try again."
done

echo "It seems that container is up and running. Now configurations"

# Setze das skeletondirectory (enthält Standard-Dateien für neue User) auf das gemountete leere Verzeichnis
sudo docker exec --user www-data nextcloud php occ config:system:set skeletondirectory --value='/tmp/myskeleton'

# Adding trusted_domains
sudo docker exec --user www-data nextcloud php occ config:system:set trusted_domains 2 --value=192.168.1.216
sudo docker exec --user www-data nextcloud php occ config:system:set trusted_domains 3 --value=pi

# User "patrick" in Nextcloud anlegen:

sudo docker exec --user www-data nextcloud php occ user:add --display-name="Patrick" --group="users" --password-from-env patrick

# Die Daten sollen ins nextcloud-Daten-Verzeichnis für User patrick kopiert werden, 
# also unter $data_directory/patrick/files. Dies ist bei nextcloud vorgegeben. 
sudo mkdir -p $data_directory/patrick/files

# Annahme: Die zu kopierenden Daten liegen unter /home/$$USRR/Pictures
sudo cp -r "/home/$USER/Pictures" "$data_directory/patrick/files/Pictures"
sudo cp -r "/home/$USER/Videos" "$data_directory/patrick/files/Videos"


# Für den Ordner "$data_directory" wird der Owner wie folgt gesetzt: 
# User "www-data" und Gruppe "pho". 
# (Wiederholung von oben)
#sudo chown -R www-data:pho "$data_directory"


# Mit occ einen File-Scan durchführen
sudo docker exec -ti --user www-data  nextcloud php occ files:scan patrick

echo "Everything finished. Now login as patrick"
