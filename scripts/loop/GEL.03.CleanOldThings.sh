#!/bin/bash


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

# enable happens only manually - generally before saving the collection
# start happens automatically everytime the machine reboot

case "$1" in
    'enable')
        ## remove older RACE stuff:
        # For the partner collection we start from the Viya 3.4 blank in AWS
        # and the collection has already been cleaned, so we comment the line.

        # sudo rm -rf /opt/RACE_Integration
        # sudo rm -f /etc/systemd/system/VirtualTunnel.service
        # sudo rm -f /etc/systemd/system/RACE_Initial.service
        # sudo rm -f /etc/systemd/system/multi-user.target.wants/VirtualTunnel.service
        # sudo rm -f /etc/systemd/system/multi-user.target.wants/RACE_Initial.service

        # sudo -u cloud-user bash -c " rm -rf ~/containers_enablement "
        # sudo -u cloud-user bash -c " rm -rf ~/OpenLDAP "
        # sudo -u cloud-user bash -c " rm -rf ~/recipes "

    ;;
    'start')
            # the first time we boot the collection we want to get rid
            # of conflicting openldap config
            reboot_file=${RACEUTILS_PATH}/.reboot.txt
            a=$(cat $reboot_file)
            if [ "$a" -eq "1" ]; then
              printf "reboot count=0, need to delete the ldap.conf file \n"
              sudo -u root bash -c " rm -rf /etc/openldap "
            fi

    ;;
    'stop')

    ;;
    'clean')
    ;;

    *)
        printf "Usage: GEL.99.clean.sh {enable/start|stop|clean} \n"
        exit 1
    ;;
esac
