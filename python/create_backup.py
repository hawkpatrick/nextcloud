#!/usr/bin/python3

import os,configparser,requests,base64,subprocess,time
import paho.mqtt.client as mqtt


def call_rsync(sourceFolder,targetFolder):
    subprocess.call(["sudo", "rsync", "-Aavx", sourceFolder, targetFolder])

def turn_harddrive_on():
    client =mqtt.Client("pi")
    client.connect("localhost")
    client.publish("zigbee2mqtt/0x7cb03eaa0a091af3/set", '{"state": "ON"}')

def turn_harddrive_off():
    client =mqtt.Client("pi")
    client.connect("localhost")
    client.publish("zigbee2mqtt/0x7cb03eaa0a091af3/set", '{"state": "OFF"}')

def get_property(fileName,sectionName,propertyName):
    config = configparser.ConfigParser()
    config.read("/home/pi/workspace/nextcloud/python/" + fileName)
    config.sections()
    return config[sectionName][propertyName]

def wait_for_directory(directoryName, timeoutSeconds):
    secondsSlept = 0
    while(secondsSlept < timeoutSeconds):
        time.sleep(5)
        secondsSlept = secondsSlept + 5
        if os.path.isdir(directoryName):
           return True
    raise RuntimeError('Failed to open path ' + directoryName) from exc

def get_mailjet_secret():
    return get_property('secrets.properties', 'EmailSection', 'mailjet.userdata')

def get_backup_root_directory():
    return get_property('env.properties', 'BackupsSection', 'backupsRootDirectory')

def get_nextcloud_data_directory():
    return get_property('env.properties', 'GeneralSection', 'nextcloudDataDirectory')

def send_email():
    url = 'https://api.mailjet.com/v3.1/send'
    payload = open('/home/pi/workspace/nextcloud/backup_success_mail.json')
    userPassword = base64.b64encode(bytes(get_mailjet_secret(), "utf-8"))
    authHeaderValue = "Basic " + str(userPassword, encoding="utf-8")
    headers = {'content-type': 'application/json', 'Authorization': authHeaderValue}
    requests.post(url, data=payload, headers=headers)


backupRootDir = get_backup_root_directory()
backupFolderName = backupRootDir + '/latest/'
nextcloudDataDir = get_nextcloud_data_directory() + '/patrick/files/'

turn_harddrive_on()
wait_for_directory(backupFolderName, 30)
call_rsync(nextcloudDataDir, backupFolderName)
turn_harddrive_off()
send_email()
