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
        printf "Cloning project the cloned project\n"

        echo "$race_alias"

        if [ "$race_alias" = "sasviya01.race.sas.com" ]  ; then
            echo "$(datestamp) $(timestamp): Initializing git project clone " >> ${RACEUTILS_PATH}/logs/${HOSTNAME}.bootstrap.log
            sudo -u cloud-user bash -c "ls -l ~"
            sudo -u cloud-user bash -c "rm -rf ~/$GIT_REPO_NAME "
            sudo -u cloud-user bash -c "cd ~ ; git clone --branch $BRANCH $GIT_CLONE_URL "
        fi

    ;;
    'start')
        printf "Updating the cloned project\n"

        echo "$race_alias"

        if [ "$race_alias" = "sasviya01.race.sas.com" ]  ; then
            echo "$(datestamp) $(timestamp): Refreshing project clone " >> ${RACEUTILS_PATH}/logs/${HOSTNAME}.bootstrap.log
            sudo -u cloud-user bash -c "ls -al ~"
            sudo -u cloud-user bash -c "cd ~ ; git clone --branch $BRANCH $GIT_CLONE_URL || (cd ~/$GIT_REPO_NAME ; git pull)"
        fi

    ;;
    'stop')

    ;;
    'clean')
        rm -rf ~/$GIT_REPO_NAME/
    ;;

    *)
        printf "Usage: GEL.00.Clone.Project.sh {enable/start|stop|clean} \n"
        exit 1
    ;;
esac
