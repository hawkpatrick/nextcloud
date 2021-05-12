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

