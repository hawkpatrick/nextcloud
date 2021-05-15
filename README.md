# Vorhaben 

## Vorrausseztung

* Alle Bilder, inklusive aktuellste Bilder sind auf Festplatte A (3TB-Festplatte, neu)
* Backup aller Bilder bis ca Mitte 2020 auch auf Festplatte B
* Bisher regelmäßige Backups der neusten Bilder auf Festplatte A
* Problem: 
  * Umständlich: Festplatte A muss erst über USB angeschlossen werden
  * Gefährlich: Aktuellste Bilder liegen nur auf A. Es gibt keinen Sync Mechanismus
  
## Plan

* NEX-1: Nextcloud läuft auf Raspberry PI
* NEX-2: Einbindung Festplatte A in Nextcloud 
  * Bilder auf Festplatte A werden in Nextcloud verfügbar gemacht
  * Neue Bilder können einfach per Nextcloud hochgeladen werden
* NEX-3: Regelmäßige Backups aller Bilder von A auf B (nächtlich)

* Constraints: 
  * Zugriff per USB weiterhin möglich, sowohl auf A als auch B
  
mv 
NEX-2a: Mounten der Festplatte generell

* Die Festplatte muss als cifs gemounted werden 


* Einloggen und das Ergebnis anschauen

NEX-2b: Berechtigungen müssen richtig gesetzt werden

# NEX-1
TODOs: 
* Beim Reboot muss der Docker-Container wieder gestartet werden

# NEX-2 

TODO: Mounten der NTFS-Festplatte als Owner: User www-data

# NEX-3

* Wöchentliches Backup von Platte A auf Platte B 
* Backups älter als 8 Wochen werden automatisch gelöscht
* E-Mail wenn Backup durchgelaufen ist

# NEX-2: Infos

# .bashrc

Es wurde folgende Zeile in /home/pi/.bashrc ergänzt, damit nextcloud beim Reboot automatisch gestartet wird: 

```
docker start nextcloud
```

# /etc/fstab

/etc/fstab wurde um 2 Zeilen für die beiden einzubindenden Festplatten ergänzt (siehe unten).

Die umask ist eine "Maske", d.h. man muss die Berechtigungen spiegelverkehrt lesen. 
uid=33 steht für: Owner der Dateien und Ordner ist User 33, also www-data (für nextcloud nötig). 
gid=1000 steht für: Ownende Gruppe ist pi, damit der User pi auf den Dateien arbeiten kann. 

Das erneute Mounten von MyBook funktioniert nur bei einem Reboot. 

Ob man PARTUUID oder UUID nimmt ist egal. Die Trekstor-Platte war im Format ntfs, MyBook in exfat. 
noatime war bei exfat in der Doku als Standard mit dabei, weshalb es bei MyBook gesetzt ist. 
```
# Trekstor
# nofail is set as we do not want to block boot when the device is not there
#        we only want it to be there for backups
PARTUUID=0f10151c-01 /media/pi/Trekstor ntfs-3g umask=007,uid=33,gid=1000,nofail 0 0

# My Book
UUID=040F-8978 /media/pi/MyBook exfat umask=007,uid=33,gid=1000,noatime 0 0
```
