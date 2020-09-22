#!/bin/bash

## if there was an existing version, we delete it, to be safe
sudo rm -rf /opt/raceutils/

## let's not assume it will always be the master branch of raceutils:
#RACEUTILS_BRANCH=master
RACEUTILS_BRANCH=master
RACEUTILS_PATH=/opt/raceutils

## now we clone
sudo git clone --single-branch --branch $RACEUTILS_BRANCH https://gelgitlab.race.sas.com/GEL/tech-partners/raceutils.git ${RACEUTILS_PATH}

## ensure logs directory is writeable
sudo chmod 777 ${RACEUTILS_PATH}/logs/
