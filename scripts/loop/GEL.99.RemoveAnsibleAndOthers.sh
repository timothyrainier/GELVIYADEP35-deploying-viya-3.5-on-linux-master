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
    sudo yum remove ansible -y
    sudo pip uninstall ansible -y
    sudo yum remove python-pip gcc python-devel -y
    sudo yum remove epel-release -y
    sudo groupdel sas

    # check
    ansible --version
    if [ $? -eq 0 ]; then
        printf "Ansible uninstall failed.\n Aborting\n"
        exit
    else
        printf "Ansible has been uninstalled\n Continuting\n"
    fi

    # remove ssh finger prints
    if test -f "/home/cloud-user/.ssh/known_hosts"; then
      printf "remove ssh finger prints\n"
      sudo -u cloud-user bash -c " rm ~/.ssh/known_hosts "
      printf "done...\n"
    fi

    # remove the "collection" folder created previously
    if [ -d "/home/cloud-user/collection" ]; then
      printf "remove the collection folder created previously\n"
      sudo -u cloud-user bash -c " rm -rf ~/collection "
      printf "done...\n"
    fi

    ;;
    'start')

    ;;
    'stop')

    ;;
    'clean')

    ;;

    *)
        printf "Usage: GEL.00.Clone.Project.sh {enable/start|stop|clean} \n"
        exit 1
    ;;
esac
