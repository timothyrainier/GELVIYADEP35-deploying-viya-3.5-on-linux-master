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



stage_collection () {
    printf "Staging Collection\n"
    logit "Staging Collection starts"

    logit "Install Ansible"

    # Install Ansible
    echo "installing EPEL"
    ## find out which rhel (6 or 7)
    if   grep -q -i "release 6" /etc/redhat-release ; then
      majversion=6
    elif grep -q -i "release 7" /etc/redhat-release ; then
      majversion=7
    else
      echo "Running neither RHEL6.x nor RHEL 7.x "
    fi
    ## install epel
    sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-$majversion.noarch.rpm
    sudo yum repolist
    sudo yum install ansible -y


    # Create a collection folder
    logit "create collection folder"


    sudo -u cloud-user bash -c "ansible  localhost -m file  \
        -a 'dest=/home/cloud-user/collection/ \
            state=directory \
            owner=cloud-user \
            group=cloud-user \
            mode=0755' "



    # Create an inventory
    INVENTORY=$(SIMSService --status=any  | awk -F'[ :]' '{print $2 " ansible_host=" $1}'  | grep -v sasclient)
    printf "$INVENTORY" | tee /home/cloud-user/collection/inventory.ini

    # Create a config
    sudo -u cloud-user bash -c "rm -f ~/collection/ansible.cfg ; ln -s  /opt/raceutils/ansible/config/ansible.cfg ~/collection/ansible.cfg "

    # symlink the roles and the vars:
    # sudo -u cloud-user bash -c "rm -f ~/collection/roles ; ln -s  /opt/raceutils/ansible/roles ~/collection/roles "
    sudo -u cloud-user bash -c "rm -f ~/.ansible/roles ; ln -s  /opt/raceutils/ansible/roles ~/.ansible/roles "
    sudo -u cloud-user bash -c "rm -f ~/collection/group_vars ; ln -s  /opt/raceutils/ansible/group_vars ~/collection/group_vars "

    # Call the staging playbook
    sudo -u cloud-user bash -c "cd ~/collection ; ansible-playbook ../GELVIYADEP35-deploying-viya-3.5-on-linux/scripts/loop/Stage.GELVIYADEP35.yml | tee -a ${RACEUTILS_PATH}/logs/${HOSTNAME}.stage.log"


    # Remove Ansible

}

function logit () {
    printf "$(datestamp) $(timestamp): $1"  | tee -a ${RACEUTILS_PATH}/logs/${HOSTNAME}.stage.log
}

case "$1" in
    'enable')

        echo "$race_alias"

        #if [ "$race_alias" = "sasviya01.race.sas.com" ]  ; then
        # For the partner collection we start from the Viya 3.4 blank in AWS
        # and the collection has already been staged, so we comment the line.
        #   stage_collection
        #fi

    ;;
    'start')

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
