# Creating a new account for Viya deployment

* [Creating a new account for Viya deployment](#creating-a-new-account-for-viya-deployment)
  * [What the customer Linux Admin would do](#what-the-customer-linux-admin-would-do)
    * [Viyadep user creation](#viyadep-user-creation)
    * [Creating an SSH key with a passphrase and distributing the public key](#creating-an-ssh-key-with-a-passphrase-and-distributing-the-public-key)
    * [Assigning SUDO rights](#assigning-sudo-rights)
  * [What the SAS Installer or the customer would have to do](#what-the-sas-installer-or-the-customer-would-have-to-do)
    * [Test with ansible ping](#test-with-ansible-ping)
    * [Test with become](#test-with-become)
    * [Perform the deployment with viyadep](#perform-the-deployment-with-viyadep)
    * [After the deployment](#after-the-deployment)
  * [Appendix - Gain some time with automation](#appendix---gain-some-time-with-automation)

In the workshop, to focus our time and attention on deployment, we have pre-configured the user "cloud-user" to be optimal. That is, it has password less SSH and unlimited password less SUDO on all machines.

This might not be the case at a customer.
Assuming ansible is already installed and configured, this walkthrough will:

* make you create a new local account (viyadep) everywhere, assign it a password
* Create a specific SSH key for this account with a passphrase in his home folder
* validate that ansible can use this account for a ping test
* give it limited, and password-prompted sudo rights
* validate ansible become commands

This is close to as difficult as it could ever get at a customer site.

If you really want to be in a real customer deployment situation, you can undeploy Viya and see if you can perform a successful deployment with your viyadep account.

## What the customer Linux Admin would do

### Viyadep user creation

The previous sections are not representative of a customer environment.

* In this hands-on, you create a user called "viyadep", and configure Ansible to use it.

    ```sh
    ## Connect to all 6 Linux machines as cloud-user in MobaXterm.

    ## create the user with a specific UID.
    sudo useradd viyadep -u 20001

    ## assign it a password
    sudo passwd viyadep

    #enter twice:
    viyapass
    viyapass
    ```

Idea: ansible has a module to do that. So instead of logging to each machine, you can try to do the same with an ansible ad hoc command (as a smart Linux administrator would do).

<!-- FOR CHEATCODES
    ```sh
    cd ~/working
    MYENCPASSWD=`python -c 'import crypt; print(crypt.crypt("viyapass"))'`
    echo $MYENCPASSWD
    ansible localhost -m user -a "name=viyadep uid=2001 password=$MYENCPASSWD" -b
    ```
-->

### Creating an SSH key with a passphrase and distributing the public key

In order to use ansible across our Viya machines, we also need SSH keys for our newly create account.

```sh
# on sasviya01
cd
su - viyadep

# create keypair
ssh-keygen -q -t rsa -b 1024  -f ~/viyadep_key

# enter your passphrase twice:
viya2018
viya2018

# copy public key out to all machines
# run the command below one by one
# when prompted, confirm by typing "yes"
# and provide the password (viyapass)
ssh-copy-id -i ~/viyadep_key.pub sasviya01
ssh-copy-id -i ~/viyadep_key.pub sasviya02
ssh-copy-id -i ~/viyadep_key.pub sasviya03
ssh-copy-id -i ~/viyadep_key.pub sascas01
ssh-copy-id -i ~/viyadep_key.pub sascas02
ssh-copy-id -i ~/viyadep_key.pub sascas03


#optionnal, test that you are not prompted for the viyadep password
ssh -i ~/viyadep_key sasviya02
#note : you will have to provide the ssh passphrase, for your ssh connection.
```

<!-- `TODO : script the above for cheatcodes`
the overall exercise could make a nice new XENO playbook...
    TODO : write ansible plays to copy the viyadep key in remote host authorized keys; to avoid password prompt

    ```sh
    ssh-keyscan -H sasviya01 >> ~/.ssh/known_hosts
    ssh-keyscan -H sasviya02 >> ~/.ssh/known_hosts
    ssh-keyscan -H sasviya03 >> ~/.ssh/known_hosts
    ssh-keyscan -H sascas01 >> ~/.ssh/known_hosts
    ssh-keyscan -H sascas01 >> ~/.ssh/known_hosts
    ssh-keyscan -H sascas01 >> ~/.ssh/known_hosts
    ```
-->

_Note: this step is required for a successful ansible ping test with the viyadep account and identity file authentication._

### Assigning SUDO rights

Example:

```sh
## this enables sudo for ALL commands as ALL users WITH PASSWORD
echo "viyadep         ALL=(ALL)       ALL " | sudo tee /etc/sudoers.d/00-viyadep
## this enables sudo for ALL commands as ALL users WITHOUT PASSWORD
#echo "# viyadep         ALL=(ALL)       NOPASSWD: ALL" | sudo tee -a /etc/sudoers.d/00-viyadep
```

As cloud-user, implement this change on all the hosts (use the policy that enables sudo for ALL commands as ALL users WITH PASSWORD).

* As an alternative you can also use ansible to do the changes with oen command from your ansible controller.

    ```sh
    cd ~/working
    ansible all -m file -a "path=/etc/sudoers.d/00-viyadep state=touch" -b
    ansible all -m lineinfile -a "path=/etc/sudoers.d/00-viyadep line='viyadep         ALL=(ALL)       ALL '" -b --diff
    ```

Now, as viyadep, you can validate your sudo privileges with:

```log
[cloud-user@aznvir01005 ~]$ su - viyadep
Password:
Last login: Fri Jan 12 08:55:52 EST 2018 on pts/0
[viyadep@aznvir01005 ~]$ sudo –l
```

Of course, depending on how you configured the sudoer file you might be prompted to provide the viyadep password (viyapass).

_Note: this step is required for a successful "ansible become" test with the viyadep account._

## What the SAS Installer or the customer would have to do

### Test with ansible ping

Now, that we have configured SSH keys and sudo privileges, let's check that we can use ansible to perform the deployment.

* Log on as the viyadep user on sasviya01

```sh
su - viyadep
```

* Create an ansible working directory and configuration as explained in section "06-Configuring Ansible to target the servers.md".

    ```sh
    cd ~
    mkdir working
    cd working
    cat << 'EOF' > ./working.inventory.ini
    [sas_all]
    sasviya01 ansible_host=intviya01.race.sas.com
    sasviya02 ansible_host=intviya02.race.sas.com
    sasviya03 ansible_host=intviya03.race.sas.com
    sascas01  ansible_host=intcas01.race.sas.com
    sascas02  ansible_host=intcas02.race.sas.com
    sascas03  ansible_host=intcas03.race.sas.com
    EOF
    cat << 'EOF' > ./ansible.cfg
    [defaults]
    log_path = ./working.log
    inventory = working.inventory.ini
    host_key_checking = true
    forks = 10
    retry_files_enabled = False
    gathering = smart
    remote_tmp = /tmp/.$USER.ansible/
    EOF
    ```

* Then perform some tests

```sh
cd ~/working
ansible all -m ping
```

The first time, you will habe to type ```yes``` a few times so the ssh host key fingerprint will be added and known for the remote hosts.
If you run the ansible ping again, then you will see something like this:

```log
sasviya01 | UNREACHABLE! => {
    "changed": false,
    "msg": "Failed to connect to the host via ssh: Permission denied (publickey,gssapi-keyex,gssapi-with-mic,password).\r\n",
    "unreachable": true
}
sascas02 | UNREACHABLE! => {
    "changed": false,
    "msg": "Failed to connect to the host via ssh: Host key verification failed.\r\n",
    "unreachable": true
}

sascas03 | UNREACHABLE! => {
    "changed": false,
    "msg": "Failed to connect to the host via ssh: Host key verification failed.\r\n",
    "unreachable": true
}

sascas01 | UNREACHABLE! => {
    "changed": false,
    "msg": "Failed to connect to the host via ssh: Host key verification failed.\r\n",
    "unreachable": true
}

sasviya02 | UNREACHABLE! => {
    "changed": false,
    "msg": "Failed to connect to the host via ssh: Host key verification failed.\r\n",
    "unreachable": true
}

sasviya03 | UNREACHABLE! => {
    "changed": false,
    "msg": "Failed to connect to the host via ssh: Host key verification failed.\r\n",
    "unreachable": true
}
```

It is not working...but actually it was expected :)
Can you see why it is not working?
Look at the error message and try to resolve it by yourself before moving to the next page.

...

...

...

...

Hopefully you noticed that there was an issue with the SSH connection. Actually, the ansible default behavior is to open the SSH connection using the user's private key located in the user's .ssh directory and called "id_rsa". But it fails as there is no such file.

Sadly, instead of falling back to the password authentication prompt method, ansible simply fails.

So we have to explicitly ask ansible to prompt us for a password. Let's see what happen if we do so:

```sh
ansible all -m ping --ask-pass
```

Now you might see this kind of messages:

```log
SSH password:
sasviya02 | FAILED! => {
    "failed": true,
    "msg": "to use the 'ssh' connection type with passwords, you must install the sshpass program"
}
sascas02 | FAILED! => {
    "failed": true,
    "msg": "to use the 'ssh' connection type with passwords, you must install the sshpass program"
}
sasviya03 | FAILED! => {
    "failed": true,
    "msg": "to use the 'ssh' connection type with passwords, you must install the sshpass program"
}
sasviya01 | FAILED! => {
    "failed": true,
    "msg": "to use the 'ssh' connection type with passwords, you must install the sshpass program"
}
sascas03 | FAILED! => {
    "failed": true,
    "msg": "to use the 'ssh' connection type with passwords, you must install the sshpass program"
}
sascas01 | FAILED! => {
    "failed": true,
    "msg": "to use the 'ssh' connection type with passwords, you must install the sshpass program"
}
```

Ok so now we are prompted but it looks like Ansible also needs the "sshpass" program.
You can install it as cloud-user with (the -b will make this task run as root):

```sh
cd ~/working
ansible localhost -m yum -a "name=sshpass state=present" -b
```

Then try the ping again.

<!--
This time you might see this message:

```log
"msg": "Using a SSH password instead of a key is not possible because Host Key checking is enabled and sshpass does not support this.  Please add this host's fingerprint to your known_hosts file to manage this host."
```

You can edit the ansible configuration (ansible.cfg) to add the following line to it:

```log
host_key_checking = false
```
-->

```sh
cd ~/working
ansible all -m ping --ask-pass
```

And now:

```log
SSH password:
sascas03 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
sascas02 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
sasviya01 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
sascas01 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
sasviya03 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
sasviya02 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

It is working!!!

Great.

But wait...we created a key at the beginning of this hands-on, didn't we?
So why not using this key, instead of a password to perform the authentication?
(Actually in a real customer situation you might only have a key and not know the password).

So let's try to run our ansible command but using a new ansible option to specify the viyadep ssh key.

```sh
ansible all -m ping --private-key=~/viyadep_key
```

```log
Enter passphrase for key '/home/viyadep/viyadep_key': Enter passphrase for key '/home/viyadep/viyadep_key': Enter passphrase for key '/home/viyadep/viyadep_key': Enter passphrase for key '/home/viyadep/viyadep_key': Enter passphrase for key '/home/viyadep/viyadep_key': Enter passphrase for key '/home/viyadep/viyadep_key':
sascas02 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}


sasviya01 | UNREACHABLE! => {
    "changed": false,
    "msg": "Failed to connect to the host via ssh: Permission denied (publickey,gssapi-keyex,gssapi-with-mic,password).\r\n",
    "unreachable": true
}
yes

Enter passphrase for key '/home/viyadep/viyadep_key':
Enter passphrase for key '/home/viyadep/viyadep_key':
Enter passphrase for key '/home/viyadep/viyadep_key':
Enter passphrase for key '/home/viyadep/viyadep_key':
Enter passphrase for key '/home/viyadep/viyadep_key':
Enter passphrase for key '/home/viyadep/viyadep_key':
sasviya02 | SUCCESS => {
    "changed": false,
    "ping": "pong"
```

Etc..
You will have an unpleasant experience, not really knowing what to type (either ```yes``` or the passphrase : ```viya2018```) and when... ansible seems to mix everything across the machines and to struggle to ask the passphrase question.

Eventually, you should be able to run the command and see all 6 host answers in green.

But in order to avoid the passphrase prompt for each host, you can type this 2 commands to store the passphrase once for all:

```sh
ssh-agent bash
ssh-add /home/viyadep/viyadep_key
```

You will have to provide the passphrase, and then the information will be stored so you are not prompted again for it in this session.
Now the simplest ping test is successful:

```sh
ansible all -m ping
```

gives:

```log
sasviya01 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
sasviya03 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
sascas02 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
sasviya02 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
sascas01 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
sascas03 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### Test with become

The next step is to ensure that with your deployment account, you can become root as it will be required when the Viya deployment playbook run certain types of command (yum install for example).

Run the command below :

```sh
ansible all -m shell -a "hostname" -b
```

You will see some errors:

```log
sascas01 | FAILED | rc=-1 >>
Missing sudo password

sasviya02 | FAILED | rc=-1 >>
Missing sudo password

sasviya01 | FAILED | rc=-1 >>
Missing sudo password

sascas02 | FAILED | rc=-1 >>
Missing sudo password

sascas03 | FAILED | rc=-1 >>
Missing sudo password

sasviya03 | FAILED | rc=-1 >>
Missing sudo password

```

As our sudoers configuration requires the viyadep password for any sudo command executed, ansible has the same requirement.

But to be able to be able to provide the password, we need to configure ansible so it can prompt us for this password.

We can do it with a command line parameter (--ask-become-pass or simply -K) or configure it globally in the ansible configuration file.

```sh
ansible all -m shell -a "hostname" -b --ask-become-pass
```

Now you get prompted and you can provide the viyadep password (viyapass):

```log
BECOME password:
sascas01 | CHANGED | rc=0 >>
intcas01.race.sas.com

sascas02 | CHANGED | rc=0 >>
intcas02.race.sas.com

sascas03 | CHANGED | rc=0 >>
intcas03.race.sas.com

sasviya02 | CHANGED | rc=0 >>
intviya02.race.sas.com

sasviya03 | CHANGED | rc=0 >>
intviya03.race.sas.com

sasviya01 | CHANGED | rc=0 >>
intviya01.race.sas.com

```

The good news is that we only have to type it once :)

### Perform the deployment with viyadep

* If already installed, uninstall the current Viya deployment with the cloud-user account.

    ```sh
    cd ~/sas_viya_playbook
    time ansible-playbook deploy-cleanup.yml
    ```

It should take between 3 and 4 minutes to run completely.
The httpd package is not uninstalled by the deploy-cleanup playbook.

* As we want to customize the Apache web server configuration for HA, we have to uninstall it before proceeding:

    ```sh
    cd ~/sas_viya_playbook
    #uninstall the httpd package
    ansible httpproxy -m yum -a "name=httpd,mod_ssl state=absent" -b
    ```

After the deploy-cleanup playbook execution, it is always a good idea to check that there are no more Viya process running on our Viya machines, such as rabbitmq...

* You could use the Viya ARK script for that:

    ```sh
    cd ~/sas_viya_playbook
    ansible-playbook viya-ark/playbooks/viya-mmsu/viya-services-stop.yml -e "enable_stray_cleanup=true"
    ```

**If they were not already executed**, perform the following tasks with the installer account (viyadep):

* Run the pre-requirement playbook (VIYA-ARK) as instructed in the [Pre-requisite section](09-Performing_the_pre-requisites.md), don't forget the "--ask-become-pass" or -K
* Run the openLDAP playbook as instructed in the [OpenLDAP deployment section](10-OpenLDAP_deployment.md), don't forget the "--ask-become-pass" or -K
* Run the system assessment playbook, don't forget the "--ask-become-pass" or -K
* Then run the installation playbook for example for a Full split deployment - follow the steps in the [Full Split Deployment section](23-1-FullSplitDeployment.md) don't forget the "--ask-become-pass" or -K

Also don't forget that each time you restart a new session, you need to register the SSH identity file with:

```sh
ssh-agent bash
ssh-add /home/viyadep/viyadep_key
```

### After the deployment

Now that the deployment with viyadep is complete. We want to reduce the viyadep privileges so the account can only be used to manage the Viya services.

Disable /bin/sh command for viyadep and give sudoers privileges to start|stop|status Viya services.

```sh
for h in `cat /tmp/hostlist`; do ssh -t $h "echo 'viyadep         ALL=(root,sas)       /etc/init.d/sas-viya-* ' | sudo tee /etc/sudoers.d/00-viyadep"; done
```

Test with viyadep account:
Register the passphrase for the session:

```ssh
su - viyadep
ssh-agent bash
ssh-add /home/viyadep/viyadep_key
```

Provide the passphrase.

```log
Enter passphrase for /home/viyadep/viyadep_key:
Identity added: /home/viyadep/viyadep_key (/home/viyadep/viyadep_key)
```

Now check the services status:

```log
[viyadep@aznvir04002 ~]$ for h in `cat /tmp/hostlist`; do ssh -t $h "sudo /etc/init.d/sas-viya-all-services status"; done
[sudo] password for viyadep:
```

So the Viyadep account has enough privileges to manage the Viya services. However, because of the sudoers configuration, we cannot use ansible and it is required to provide the viyadep password for each machine, when we call the "service" command.

## Appendix - Gain some time with automation

<!-- TODO : TO TEST WITH CHEAT CODE sshkeyscan might be needed -->

Some of the Linux administrator tasks described in the first section of this hands-on, such as the users and keys creation, but also the sudoers configuration can become very tedious (especially if you have a high number of machines in your deployment). This section provides scripts or ansible commands that you can run instead of logging to each machines to run individual commands.

If ansible is not installed:

* First create a file with the hosts list:

    ```sh
    cat << 'EOF' > /tmp/hostlist
    sasviya01
    sasviya02
    sasviya03
    sascas01
    sascas02
    sascas03
    EOF
    ```

* Create a script to add the user viyadep on all machines:

    ```sh
    cat << 'EOF' > ./addlocaluser.sh
    #!/bin/sh
    for h in `cat /tmp/hostlist`
    do
    echo create user $1 on $h
    ssh -t $h sudo adduser $1 -u 20001
    ssh -t $h "sudo echo viyapass | sudo passwd --stdin $1"
    echo; echo "User $1’s password changed!"
    done
    EOF
    ```

* Now make the script executable and run it as cloud-user:

    ```bash
    chmod u+x ./addlocaluser.sh;./addlocaluser.sh viyadep
    ```

* If ansible is installed, simply run:

    ```sh
    ansible sas_all -m user -a 'name=viyadep state=present password=$6$g7RP3FHFkk2kAPsh$H2Hm2ISD7xdLSlgg7tQxusoZD8YXh09rg2s47iT9HIQM2Gr126lGjQ9p/GEExrspr7Emt1HX7b5uH02PANTLt1 uid=20001' -b
    ```

It creates the viyadep user on all the machine with 20001 as UID and viyapass as the password.

_Note: ensure that you are using simple quote to convey the encrypted version of the password._

* Run the command below with cloud-user to configure the sudoers across all the machines

    ```sh
    for h in `cat /tmp/hostlist`; do ssh -t $h "echo 'viyadep         ALL=(ALL)       ALL ' | sudo tee /etc/sudoers.d/00-viyadep"; done
    ```

* Or to be more restrictive, only allow commands following the ansible pattern:

    ```sh
    for h in `cat /tmp/hostlist`; do ssh -t $h "echo 'viyadep ALL = (sas, cas, root) /bin/sh -c echo *' | sudo tee /etc/sudoers.d/00-viyadep"; done
    ```
