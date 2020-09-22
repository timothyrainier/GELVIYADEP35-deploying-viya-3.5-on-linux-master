# Commnands to enable this project in a collection

1. go to every linux machine in the collection:

    ```sh
    bootstrap=https://gelgitlab.race.sas.com/GEL/tech-partners/raceutils/raw/master/bootstrap/
    curl -fsSL ${bootstrap}/bootstrap.collection.sh -o /tmp/bootstrap.collection.sh
    sudo bash  /tmp/bootstrap.collection.sh enable https://gelgitlab.race.sas.com/GEL/tech-partners/GELVIYADEP35-deploying-viya-3.5-on-linux.git master
    #sudo bash  /tmp/bootstrap.collection.sh start
    ```

1. while developing

    ```sh

    #enable on all
    ansible raph -b -m shell -a    "bootstrap=https://gelgitlab.race.sas.com/GEL/tech-partners/raceutils/raw/master/bootstrap/ ;  \
                              curl -fsSL \${bootstrap}/bootstrap.collection.sh -o /tmp/bootstrap.collection.sh ;  \
                               bash  /tmp/bootstrap.collection.sh enable https://gelgitlab.race.sas.com/GEL/tech-partners/GELVIYADEP35-deploying-viya-3.5-on-linux.git master"

    #ansible raph -b -m shell -a "/opt/raceutils/bootstrap/loop/GEL.01.identify.sh start"
    ansible raph -b -m shell -a "reboot"
    ansible raph  -m shell -a "ls -l ~/ "
    ansible raph  -m shell -a "ls -l /opt "
    ansible raph  -m shell -a "ls -l /opt/raceutils/ "
    ansible raph  -m shell -a "ls -l /opt/raceutils/logs "

    ansible raph  -m shell -a "ls -l /etc/systemd/system/ "
    ansible raph  -m shell -a "ls -l /etc/systemd/system/multi-user.target.wants/ "
    ansible raph  -m shell -a "cat /etc/hosts"
    ansible raph  -m shell -a "hostname -f "


    ```
