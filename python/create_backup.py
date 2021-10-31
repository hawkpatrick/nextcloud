#!/usr/bin/python3

import os,configparser,requests,base64,subprocess,time
import paho.mqtt.client as mqtt


def get_property(fileName,sectionName,propertyName):
    config = configparser.ConfigParser()
    config.read("/home/pi/workspace/nextcloud/python/" + fileName)
    config.sections()
    return config[sectionName][propertyName]


def get_mailjet_secret():
    return get_property('secrets.properties', 'EmailSection', 'mailjet.userdata')


def get_backup_root_directory():
    return get_property('env.properties', 'BackupsSection', 'backupsRootDirectory')


def get_nextcloud_data_directory():
    return get_property('env.properties', 'GeneralSection', 'nextcloudDataDirectory')



def wait_for_directory_unmounted(directoryName, timeoutSeconds):
    print("Waiting unitl directory " + directoryName + " is unmounted")
    secondsSlept = 0
    while(secondsSlept < timeoutSeconds):
        time.sleep(5)
        secondsSlept = secondsSlept + 5
        if not os.path.isdir(directoryName):
           print("Directory " + directoryName + " is unmounted")
           return True
    raise RuntimeError('Failed to open path ' + directoryName) from exc


def wait_for_directory_mounted(directoryName, timeoutSeconds):
    print("Waiting until directory " + directoryName + " is mounted")
    secondsSlept = 0
    while(secondsSlept < timeoutSeconds):
        time.sleep(5)
        secondsSlept = secondsSlept + 5
        if os.path.isdir(directoryName):
           print("Directory " + directoryName + " is mounted")
           return True
    raise RuntimeError('Failed to open path ' + directoryName) from exc


def call_rsync(sourceFolder,targetFolder):
    cmd = "sudo rsync -Aavx " + sourceFolder + " " + targetFolder
    results = subprocess.run(cmd, shell=True, universal_newlines=True, check=True)
    print("rsync returned following result:")
    print(results.stdout)


def unmount_harddrive():
    cmd = "sudo umount /media/pi/Trekstor"
    subprocess.Popen(str(cmd), shell=True, stdout=subprocess.PIPE)


def mount_harddrive():
    print("Mounting harddrive /media/pi/Trekstor")
    cmd = "sudo mount /media/pi/Trekstor"
    subprocess.Popen(str(cmd), shell=True, stdout=subprocess.PIPE)


def turn_harddrive_on():
    print("Turning harddrive device on")
    client = mqtt.Client("pi")
    client.connect("localhost")
    client.publish("zigbee2mqtt/0x7cb03eaa0a091af3/set", '{"state": "ON"}')
    mount_harddrive() 
    wait_for_directory_mounted(get_backup_root_directory(), 30)


def turn_harddrive_off():
    unmount_harddrive()
    wait_for_directory_unmounted(get_backup_root_directory(), 30) 
    print("Turing harddrive device off")
    client = mqtt.Client("pi")
    client.connect("localhost")
    client.publish("zigbee2mqtt/0x7cb03eaa0a091af3/set", '{"state": "OFF"}')


def send_email():
    print("Sending success email")
    url = 'https://api.mailjet.com/v3.1/send'
    payload = open('/home/pi/workspace/nextcloud/backup_success_mail.json')
    userPassword = base64.b64encode(bytes(get_mailjet_secret(), "utf-8"))
    authHeaderValue = "Basic " + str(userPassword, encoding="utf-8")
    headers = {'content-type': 'application/json', 'Authorization': authHeaderValue}
    requests.post(url, data=payload, headers=headers)


def create_backup():
    backupRootDir = get_backup_root_directory()
    backupFolderName = backupRootDir + '/latest/'
    nextcloudDataDir = get_nextcloud_data_directory() + '/patrick/files/'

    turn_harddrive_on()
    call_rsync(nextcloudDataDir, backupFolderName)
    turn_harddrive_off()
    send_email()

create_backup()
