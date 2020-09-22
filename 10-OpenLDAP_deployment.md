# OpenLDAP deployment

* [Foreword](#foreword)
* [Cloning the homegrown files](#cloning-the-homegrown-files)
* [Deploy OpenLDAP using the homegrown playbook](#deploy-openldap-using-the-homegrown-playbook)

## Foreword

If you remember the discussions about pre-requisites, you remember that we ABSOLUTELY need an LDAP (Active Directory, or any other type of LDAP).

However, at this point, you don't yet have an LDAP you can use.
We could connect to SAS's Active Directory, but because we are working in EXNET, we cannot connect to the main SAS network.

Instead, we will install and configure our own LDAP, using a software called OpenLDAP.

Note that this has nothing to do with Viya. In a customer scenario, we would ask that the customer provides us with access to their LDAP. If a customer does not have an accessible LDAP, we would ask them to obtain one.

To make the deployment of OpenLDAP quick and painless for this workshop, we will use a home-grown Ansible playbook.

## Cloning the homegrown files

1. Now, we are going to clone the following project.

    ```bash
    cd ~/working/
    rm -rf ~/working/homegrown/
    mkdir -p ~/working/homegrown/
    cd ~/working/homegrown/
    git clone https://gelgitlab.race.sas.com/GEL/tech-partners/openldap.git
    ls -al openldap
    ```

1. The output should end with:

    ```log
    total 28
    drwxrwxr-x. 5 cloud-user cloud-user  185 Oct 25 15:59 .
    drwxrwxr-x. 3 cloud-user cloud-user   22 Oct 25 15:59 ..
    -rw-rw-r--. 1 cloud-user cloud-user  157 Oct 25 15:59 ansible.cfg
    -rw-rw-r--. 1 cloud-user cloud-user  217 Oct 25 15:59 CHANGELOG.md
    -rw-rw-r--. 1 cloud-user cloud-user 2611 Oct 25 15:59 gel.openldapremove.yml
    -rw-rw-r--. 1 cloud-user cloud-user 2380 Oct 25 15:59 gel.openldapsetup.yml
    drwxrwxr-x. 8 cloud-user cloud-user  163 Oct 25 15:59 .git
    drwxrwxr-x. 2 cloud-user cloud-user  145 Oct 25 15:59 group_vars
    -rw-rw-r--. 1 cloud-user cloud-user 2594 Oct 25 15:59 inventory.ini
    -rw-rw-r--. 1 cloud-user cloud-user 4764 Oct 25 15:59 README.md
    drwxrwxr-x. 5 cloud-user cloud-user   85 Oct 25 15:59 roles
    ```

## Deploy OpenLDAP using the homegrown playbook

1. Log onto the Ansible Controller.
1. Go to the openldap folder.

    ```bash
    cd ~/working/homegrown/openldap
    ```

1. backup the default inventory

    ```bash
    cp inventory.ini inventory.ini.orig
    ```

1. create a new inventory

    ```bash
    cat << 'EOF' > ./inventory.ini
    sasviya01 ansible_host=intviya01.race.sas.com
    sasviya02 ansible_host=intviya02.race.sas.com
    sasviya03 ansible_host=intviya03.race.sas.com
    sascas01  ansible_host=intcas01.race.sas.com
    sascas02  ansible_host=intcas02.race.sas.com
    sascas03  ansible_host=intcas03.race.sas.com

    [openldapserver]
    sasviya01

    [openldapclients]
    sasviya01
    sasviya02
    sasviya03
    sascas01
    sascas02
    sascas03


    [openldapall:children]
    openldapserver
    openldapclients

    EOF
    ```

1. Before executing the playbook, look at the default values of the variables:

    ```sh
    cat ./group_vars/all.yml
    ```

1. Execute the playbook with some specific overrides. These determine the default passwords, and the way the sitedefault will get generated:

    ```bash
    cd ~/working/homegrown/openldap
    ansible-playbook gel.openldapsetup.yml -e "OLCROOTPW=lnxsas" -e 'anonbind=true' -e 'use_pause=no'
    ```

1. A successful run would look like:

    ```log
    PLAY RECAP *******************************************************************************************************************************************
    localhost                  : ok=3    changed=0    unreachable=0    failed=0
    sascas01                   : ok=29   changed=14   unreachable=0    failed=0
    sascas02                   : ok=29   changed=14   unreachable=0    failed=0
    sascas03                   : ok=29   changed=14   unreachable=0    failed=0
    sasviya01                  : ok=88   changed=55   unreachable=0    failed=0
    sasviya02                  : ok=29   changed=14   unreachable=0    failed=0
    sasviya03                  : ok=29   changed=14   unreachable=0    failed=0
    ```

1. If you have made a mistake, you can easily uninstall and re-install:

    ```sh
    cd ~/working/homegrown/openldap
    ansible-playbook gel.openldapremove.yml
    ## fix your mistake, update what you need to update
    ```

    ```sh
    ansible-playbook gel.openldapsetup.yml -e "OLCROOTPW=lnxsas" -e 'anonbind=true' -e 'use_pause=no'
    ```

1. Now, we need to confirm that the LDAP-based accounts are working. First, from the Ansible Controller, run:

    ```bash
    ## Check the OS knows about this account
    ansible all -m shell -a "id viyademo01"
    ```

    ```log
    sasviya01 | SUCCESS | rc=0 >>
    uid=100001(viyademo01) gid=100001(marketing) groups=100001(marketing)

    sasviya02 | SUCCESS | rc=0 >>
    uid=100001(viyademo01) gid=100001(marketing) groups=100001(marketing)

    sasviya03 | SUCCESS | rc=0 >>
    uid=100001(viyademo01) gid=100001(marketing) groups=100001(marketing)

    sascas01 | SUCCESS | rc=0 >>
    uid=100001(viyademo01) gid=100001(marketing) groups=100001(marketing)

    sascas02 | SUCCESS | rc=0 >>
    uid=100001(viyademo01) gid=100001(marketing) groups=100001(marketing)

    sascas03 | SUCCESS | rc=0 >>
    uid=100001(viyademo01) gid=100001(marketing) groups=100001(marketing)
    ```

    ```bash
    ## is the account a local account (stored in /etc/passwd)?
    ansible all -m shell -a "grep viyademo /etc/passwd"
    ```

    ```log
    sasviya01 | FAILED | rc=1 >>
    non-zero return code

    sasviya02 | FAILED | rc=1 >>
    non-zero return code

    sasviya03 | FAILED | rc=1 >>
    non-zero return code

    sascas02 | FAILED | rc=1 >>
    non-zero return code

    sascas01 | FAILED | rc=1 >>
    non-zero return code

    sascas03 | FAILED | rc=1 >>
    non-zero return code
    ```

    ```bash
    ## get more details about the account
    ansible all -m shell -a "getent passwd viyademo01"
    ```

    ```log
    sasviya01 | SUCCESS | rc=0 >>
    viyademo01:*:100001:100001:Viya Demo User 01:/home/viyademo01:/bin/

    sasviya02 | SUCCESS | rc=0 >>
    viyademo01:*:100001:100001:Viya Demo User 01:/home/viyademo01:/bin/

    sasviya03 | SUCCESS | rc=0 >>
    viyademo01:*:100001:100001:Viya Demo User 01:/home/viyademo01:/bin/

    sascas01 | SUCCESS | rc=0 >>
    viyademo01:*:100001:100001:Viya Demo User 01:/home/viyademo01:/bin/

    sascas02 | SUCCESS | rc=0 >>
    viyademo01:*:100001:100001:Viya Demo User 01:/home/viyademo01:/bin/

    sascas03 | SUCCESS | rc=0 >>
    viyademo01:*:100001:100001:Viya Demo User 01:/home/viyademo01:/bin/
    ```

1. Then, connect to a server other than sasviya01 and verify that you can log in as a few of the user ldap users:

    ```sh
    ssh sascas02
    ```

1. Log in as viyademo01 to make sure the password works

    ```sh
    su - viyademo01
    ## the password should be lnxsas
    ```

1. Once that is done, exit twice, to get back to the Ansible Controller:

    ```sh
    exit
    exit
    ```

1. Now, back on the Ansible Controller (sasviya01) you need to look at the details of the newly create LDAP. The playbook creates a file called sitedefault.yml:

    ```bash
    cat ~/working/homegrown/openldap/sitedefault.yml ; echo
    ```

1. This file gives you the information you need to input into SAS Viya to get it connected to this newly-configured LDAP. You can either do that manually through the SAS Environment Manager Interface, or we can use this file inject the content into the environment during deployment.
We will use this file later!
