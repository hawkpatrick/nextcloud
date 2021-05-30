#!/bin/python3

import paho.mqtt.client as mqtt 

client =mqtt.Client("test")

client.connect("localhost")

client.publish("zigbee2mqtt/0x7cb03eaa0a091af3/set", '{"state": "OFF"}')


