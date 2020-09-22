#!/bin/bash

timestamp() {
  date +"%T"
}
datestamp() {
  date +"%D"
}

## Read in the id file. only really needed if running these scripts in standalone mode.
source <( cat /opt/raceutils/.bootstrap.txt  )
source <( cat /opt/raceutils/.id.txt  )

case "$1" in
    'enable')

    ;;
    'start')

        if [ "$race_alias" = "sasviya01.race.sas.com" ]  ; then
            echo "$(datestamp) $(timestamp): Creating cheatcodes " >> ${RACEUTILS_PATH}/logs/${HOSTNAME}.bootstrap.log
            sudo -u cloud-user bash -c "$RACEUTILS_PATH/cheatcodes/create.cheatcodes.sh ~/GELVIYADEP35-deploying-viya-3.5-on-linux "
        fi

    ;;
    'stop')

    ;;
    'clean')

    ;;

    *)
        printf "Usage: GEL.04.Create.Cheatcodes.sh {enable/start|stop|clean} \n"
        exit 1
    ;;
esac


