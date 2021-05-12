#!/bin/bash

docker stop nextcloud
docker rm nextcloud
sudo rm -r data
