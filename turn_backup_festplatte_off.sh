#!/bin/bash

set -e

sudo umount /media/pi/Trekstor

# Steckdose ausschalten
mosquitto_pub -h localhost -t zigbee2mqtt/0x7cb03eaa0a091af3/set -m '{"state": "OFF"}'
