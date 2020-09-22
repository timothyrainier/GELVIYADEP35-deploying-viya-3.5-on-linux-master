# Configure remote HDFS Access

* [Configure remote HDFS Access](#configure-remote-hdfs-access)
  * [Reference the Hadoop machines](#reference-the-hadoop-machines)
  * [Configure the ssh keys for an end-user](#configure-the-ssh-keys-for-an-end-user)
  * [Usa SAS Studio (basic) to save your CAS table in the remote HDFS](#usa-sas-studio-basic-to-save-your-cas-table-in-the-remote-hdfs)
  * [Check the table in Hadoop](#check-the-table-in-hadoop)
  * [Configure the ssh key for cas](#configure-the-ssh-key-for-cas)

In earlier Viya releases, the CAS server could access either a single co-located cluster or a single remote cluster for use with HDFS CASLibs (as in the very simplified schema below).
With Viya 3.5, the server can now assign caslibs to remote HDFS clusters on a caslib-by-caslib basis. The CAS tables can then be saved or loaded to/from HDFS using either the native SASHDAT format or CSV.

In this excercise, we will see how configure and use it.

There are basically 2 requirements:

* The SAS plug-in for Hadoop must be installed on the HDFS nodes.
* SSH keys must be configured for passwordless access from any CAS node to any HDFS node (for the account(s) using the HDFS caslib).

As there is no remote hadoop cluster as part of this collection, in this particular Hands-on we use a common Hadoop collection which is part of the VLE workshop standby collection)

The SAS plug-ins for Hadoop have been already installed in the remote Hadoop cluster as documented in the official [documentation](https://go.documentation.sas.com/?docsetId=dplyml0phy0lax&docsetTarget=n19vqh36tmtqdqn1inklwthshxlw.htm&docsetVersion=3.5&locale=en).

## Reference the Hadoop machines

Here are the IP adresses and hostnames of the HDFS machines, that we want to use:

```log
10.96.14.73 sashdp01.race.sas.com sashdp01 (HDFS NameNode)
10.96.10.203 sashdp02.race.sas.com sashdp02 (HDFS DataNode)
10.96.14.5 sashdp03.race.sas.com sashdp03 (HDFS DataNode)
10.96.5.139 sashdp04.race.sas.com sashdp04 (HDFS DataNode)
```

Warning : the information above is subject to change

Each CAS node needs to be able to access each HDFS node. So the first thing to do will be to add the HDFS nodes IP adresses and hostnames in the /etc/hosts file for each CAS worker.

* First let's create an inventory that we will use for the configuration.

    ```bash
    cat > ~/sas_viya_playbook/remote_hdfs.ini << EOF
    sascas01 ansible_host=intcas01.race.sas.com
    sascas02 ansible_host=intcas02.race.sas.com
    sascas03 ansible_host=intcas03.race.sas.com
    sashdp01 ansible_host=sashdp01.race.sas.com
    sashdp02 ansible_host=sashdp02.race.sas.com
    sashdp03 ansible_host=sashdp03.race.sas.com
    sashdp04 ansible_host=sashdp04.race.sas.com

    [casnodes]
    sascas01
    sascas02
    sascas03

    [hdpnodes]
    sashdp01
    sashdp02
    sashdp03
    sashdp04
    EOF
    ```

* Now create a small playbook and to update the /etc/hosts file on the CAS nodes :

    ```bash
    cat > /tmp/insertHDPHostsBlock.yml << EOF
    ---
    - hosts: casnodes,localhost
      tasks:
      - name: Remove any existing previous sashdp reference
        lineinfile:
          path: /etc/hosts
          state: absent
          regexp: 'sashdp'
      - name: Insert HDP Hosts block for remote CAS access
        blockinfile:
          path: /etc/hosts
          backup: yes
          insertafter: EOF
          block: |
            10.96.10.203 sashdp02.race.sas.com sashdp02
            10.96.5.139 sashdp04.race.sas.com sashdp04
            10.96.14.73 sashdp01.race.sas.com sashdp01
            10.96.14.5 sashdp03.race.sas.com sashdp03
    EOF
    ```

* and run it using our inventory file :

    ```bash
    cd ~/sas_viya_playbook
    ansible-playbook /tmp/insertHDPHostsBlock.yml  -i remote_hdfs.ini --diff -b
    ```

## Configure the ssh keys for an end-user

In a first scenario we want to connect in SAS Studio Basic and save a CAS table in the remote HDFS cluster using the new caslib options.
We plan to use the viyademo01 account to run our code to interact with the remote HDFS cluster.

Normally to allow the viyademo01 account to connect to the Hadoop cluster you would need to :

1. Ensure that the viyademo01 account exist on the HDFS machines.
1. Create a RSA ssh key pair for viyademo01
1. Implement it on all the CAS nodes for the viyademo01 account.
1. Distribute the viyademo01 public ssh key on the HDFS machines and add it in the authorized keys file, so viyademo01 can ssh transparently to any HDFS node from any CAS node.

In our environment, as we will all use the viyademo01 account, we want to use the same ssh key.

The SSH private key (for the viyademo01 account) that corresponds to the public key implemented in the HDFS cluster is :

```log
-----BEGIN RSA PRIVATE KEY-----
MIIEpQIBAAKCAQEA6S7Kbp2tZXU+1NUz93yBV6Yd3C/djuGxUUeVyC6j6CN9H2eZ
4gf7LZM7kkexA8/XawMIphHFVnlsz+S4UQAvzIEyhR60MoJfV5FbDcc5vS9xu+YJ
HSgPDkWfJybTIEWG4bWrpmqA26sqpbKuMTOqoDMJSA4OsGMjErfIG3k7VF5adTm4
f+oeFwWIuV2c5m6LY6TSvWmVbEiPiSYs9UELuu8jNp7tkd9IYYorTkiVu2WpHfkZ
yZDNLrwndQLWDG9tKFbvoF8+Xb8pvqSa/gTn7OM/4z3f03oPL2GYKovePmssl15O
0Sb0FeGoU8ubvSsePBZXG+TMnpZf0XS0K4qr4QIDAQABAoIBAQCOfuKD4GVi99gS
lcsw9OvRlRjwQmvhcbg7FETK1P2i0XUX6OaXwwrSmgOwa5EX5D4fDfaODZQLOR6u
mHWuQi/ziAxIXy/9IcCDsbbz34hAPSsCiRuOrrksno0Yjtg8A2Des3cWtkTSeHIS
WfOq64jcZvPIDZcaYSrAuIBXkakY73jxqZArRSUQQj6ZqyEFpUdhAFfqYiylHS4p
kOSJRpVL4mwdYsLOCDI5vvAwhu1kcZYaJ4FylFvF2Y+LHoursLg1X2+qg0E/Zy3h
OnVl242orRN3X9D+tTcxsctFND5EqVm6NDpnPjZddVC5LM6yQWbqfBH5ddd2sJrv
WLiSr0WFAoGBAP8XSxgnVhkFn/S+o8sC+355/je+Xl75oNrLdnrqlNew7FpGLPNX
LdpYYtNmUyUxT+C3PR6WLvv1flYvbpIp1hbE6r+hekwIIb6flqvW2cazsVdJdJqB
EkiFfcuZ0BZcY1xmVhsqqRgaVNIDTK2Knrm1CQ8Pka1o+FeQDhHvqNO/AoGBAOoD
gvu5H59l3goU6PBD+CD9HD9afVaa43bzESS495oF7zmSC+Suvi/cB8KVABvQsXEC
XE5JHD4eiGlc298hWTFTc2qx/z04jAepthHfjQkL+NhEDxv5V4i+RkiRK9oH6bdn
0dHXPADXi4t3I7VotWj/E+aaPqyBRKjJ6g6nwehfAoGAcARfkpS7hzNkIYqRzLVb
kRerHfl34YcHLu1H8wQOJoVn1OCaHqW62fYUN7bobh2wcQKmUUcsDLKqLtiXWpIK
lGcWmt4jIT4060uTU5R+f3YrOyRjkvF5AOW17vF1YkxhyZKa30UlihMOCkcupcqI
lw47kySIGTlOTM1SkGfIoGsCgYEA3fdUv5W55ATI1sE8reGasxfCOmmHp6UlCsfF
xBJacVMdtXrNIy2IonbPOYcBYmDSXkIB8hOw4U8uztnQiFXmdz4TpOmPE6/WStJ0
K4HjEei0MdZkioE4wTDSE7T3ZkjJLDkisSq59IZ/C1uHmGPoZt5ELyCxQAkhagST
qTEAYXsCgYEA2KN9sR1uczkBvhgVK4ZmEC7NJJ8tKIWEH94SbNtXxiWwWvw7kDV5
oDI53t7QUmHX4fT0lRiNzxeqWpYdbrUrF6LAV7Gc4iaTGUkrmmJT4YNJwzpqezP7
FIkDXGmey4nhYP/EhnYJvlLWoxzPpGg/P/1TknvLXEv3CElJigb6jxg=
-----END RSA PRIVATE KEY-----
```

What we need to do is to implement this key in our CAS nodes.

* Let's create a small playbook to do it :

    ```bash
    cat > /tmp/setviyademo01privkey.yml << EOF
    ---
    - hosts: casnodes
      gather_facts: false
      become: yes
      become_user: root

      tasks:
      - name: ensure .ssh folder exists
        file:
          path: "{{ homedir }}/viyademo01/.ssh/"
          state: directory
          mode: '0700'
          owner: viyademo01
        tags:
          - dotsshfolder

      - name: ensure the id_rsa file exists
        file:
          path: "{{ homedir }}/viyademo01/.ssh/id_rsa"
          state: touch
          mode: '0700'
          owner: viyademo01
        tags:
          - idrsatouch

      - name: Insert private key in the id_rsa
        blockinfile:
          path: "{{ homedir }}/viyademo01/.ssh/id_rsa"
          backup: yes
          insertafter: BOF
          block: |
            -----BEGIN RSA PRIVATE KEY-----
            MIIEpQIBAAKCAQEA6S7Kbp2tZXU+1NUz93yBV6Yd3C/djuGxUUeVyC6j6CN9H2eZ
            4gf7LZM7kkexA8/XawMIphHFVnlsz+S4UQAvzIEyhR60MoJfV5FbDcc5vS9xu+YJ
            HSgPDkWfJybTIEWG4bWrpmqA26sqpbKuMTOqoDMJSA4OsGMjErfIG3k7VF5adTm4
            f+oeFwWIuV2c5m6LY6TSvWmVbEiPiSYs9UELuu8jNp7tkd9IYYorTkiVu2WpHfkZ
            yZDNLrwndQLWDG9tKFbvoF8+Xb8pvqSa/gTn7OM/4z3f03oPL2GYKovePmssl15O
            0Sb0FeGoU8ubvSsePBZXG+TMnpZf0XS0K4qr4QIDAQABAoIBAQCOfuKD4GVi99gS
            lcsw9OvRlRjwQmvhcbg7FETK1P2i0XUX6OaXwwrSmgOwa5EX5D4fDfaODZQLOR6u
            mHWuQi/ziAxIXy/9IcCDsbbz34hAPSsCiRuOrrksno0Yjtg8A2Des3cWtkTSeHIS
            WfOq64jcZvPIDZcaYSrAuIBXkakY73jxqZArRSUQQj6ZqyEFpUdhAFfqYiylHS4p
            kOSJRpVL4mwdYsLOCDI5vvAwhu1kcZYaJ4FylFvF2Y+LHoursLg1X2+qg0E/Zy3h
            OnVl242orRN3X9D+tTcxsctFND5EqVm6NDpnPjZddVC5LM6yQWbqfBH5ddd2sJrv
            WLiSr0WFAoGBAP8XSxgnVhkFn/S+o8sC+355/je+Xl75oNrLdnrqlNew7FpGLPNX
            LdpYYtNmUyUxT+C3PR6WLvv1flYvbpIp1hbE6r+hekwIIb6flqvW2cazsVdJdJqB
            EkiFfcuZ0BZcY1xmVhsqqRgaVNIDTK2Knrm1CQ8Pka1o+FeQDhHvqNO/AoGBAOoD
            gvu5H59l3goU6PBD+CD9HD9afVaa43bzESS495oF7zmSC+Suvi/cB8KVABvQsXEC
            XE5JHD4eiGlc298hWTFTc2qx/z04jAepthHfjQkL+NhEDxv5V4i+RkiRK9oH6bdn
            0dHXPADXi4t3I7VotWj/E+aaPqyBRKjJ6g6nwehfAoGAcARfkpS7hzNkIYqRzLVb
            kRerHfl34YcHLu1H8wQOJoVn1OCaHqW62fYUN7bobh2wcQKmUUcsDLKqLtiXWpIK
            lGcWmt4jIT4060uTU5R+f3YrOyRjkvF5AOW17vF1YkxhyZKa30UlihMOCkcupcqI
            lw47kySIGTlOTM1SkGfIoGsCgYEA3fdUv5W55ATI1sE8reGasxfCOmmHp6UlCsfF
            xBJacVMdtXrNIy2IonbPOYcBYmDSXkIB8hOw4U8uztnQiFXmdz4TpOmPE6/WStJ0
            K4HjEei0MdZkioE4wTDSE7T3ZkjJLDkisSq59IZ/C1uHmGPoZt5ELyCxQAkhagST
            qTEAYXsCgYEA2KN9sR1uczkBvhgVK4ZmEC7NJJ8tKIWEH94SbNtXxiWwWvw7kDV5
            oDI53t7QUmHX4fT0lRiNzxeqWpYdbrUrF6LAV7Gc4iaTGUkrmmJT4YNJwzpqezP7
            FIkDXGmey4nhYP/EhnYJvlLWoxzPpGg/P/1TknvLXEv3CElJigb6jxg=
            -----END RSA PRIVATE KEY-----
        tags:
          - insertkeyinfile
    EOF
    ```

<!-- Keep the block below as it can be useful in case we lose the HDFS cluster
Here is the corresponding public key that was implemented in the HDFS cluster.
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDpLspuna1ldT7U1TP3fIFXph3cL92O4bFRR5XILqPoI30fZ5niB/stkzuSR7EDz9drAwimEcVWeWzP5LhRAC/MgTKFHrQygl9XkVsNxzm9L3G75gkdKA8ORZ8nJtMgRYbhtaumaoDbqyqlsq4xM6qgMwlIDg6wYyMSt8gbeTtUXlp1Obh/6h4XBYi5XZzmbotjpNK9aZVsSI+JJiz1QQu67yM2nu2R30hhiitOSJW7Zakd+RnJkM0uvCd1AtYMb20oVu+gXz5dvym+pJr+BOfs4z/jPd/Teg8vYZgqi94+ayyXXk7RJvQV4ahTy5u9Kx48Flcb5Myell/RdLQriqvh ansible-generated on intcas01.race.sas.com -->

* Now run the playbook:

    ```bash
    cd ~/sas_viya_playbook
    ansible-playbook /tmp/setviyademo01privkey.yml -i remote_hdfs.ini -e "homedir=/sharedhome" -b
    ```

Note: you might notice that the viyademo01's home directory to use for the SSH keys is passed as a variable.
If you skipped the HA exercise, you need to use "/home" as the viyademo Home directory.

To make sure that our key is working, connect to intcas01 as cloud-user and run the following code :

```sh
sudo su - viyademo01
ssh sashdp01
```

You should be prompted for the host finger print (as it is the first time you connect), but not for a password:

```log
The authenticity of host 'sashdp01 (10.96.14.73)' can't be established.
ECDSA key fingerprint is SHA256:P0MGN+SkohPBvOjEurfdo74a6XPp4kjYLO/W/wRkP+8.
ECDSA key fingerprint is MD5:87:95:02:4c:38:56:87:d7:45:72:72:9f:65:78:85:cb.
Are you sure you want to continue connecting (yes/no)?
```

Type "yes", hit "enter" and then should get connected to the sashdp01 machine without having to provide any password.
Make sure you exit and test access to sashdp02 to sashdp04.

There is also an automated way to validate that the SSH keys are working for a passwordless connection.

* Run the ansible command below to trigger a connection with the viyademo01 account, from the CAS nodes to all the HDFS nodes:

    ```bash
    ansible casnodes -i remote_hdfs.ini -m shell -a "for h in sashdp0{1..4};do ssh -o \"StrictHostKeyChecking=no\" \$h \"whoami;hostname -f\" ;done" --become-user viyademo01 -b
    ```

## Usa SAS Studio (basic) to save your CAS table in the remote HDFS

For this excercise, we need to use SAS Studio Basic.

* So let's make sure the SAS Studio Basic service is running :

    ```bash
    # Ensure name=sas-viya-sasstudio-default is up and running.
    cd ~/sas_viya_playbook
    ansible programming -m service -a "name=sas-viya-sasstudio-default state=started" -b
    ```

Open SAS Studio (Basic, NOT the Enterprise version) in Google Chrome : (https://sasviya02.race.sas.com/SASStudio), login as viyademo01 (password is lnxsas).

Create a new SAS program, copy-paste the code below.

Adjust the "mytab" macro variable to use your own SAS ID (every attendee should create it's own file in HDFS so we will avoid conflicts) and hit F3.

```sh
cas mysess;
caslib testhdat datasource=(srctype="hdfs", enableRemoteSave=TRUE, hadoopHome="/usr/hdp/2.6.3.0-235/hadoop", hadoopNameNode="sashdp01") path="/tmp";

%let mytab=frarpo_zip;
/*load the sashelp.zipcode table into CAS*/
proc casutil;
   load data=sashelp.zipcode;
run;

/*Save the zipcode CAS table in HDFS with the CSV format*/
proc casutil;
   save casdata="zipcode" casout="&mytab..csv" outcaslib="testhdat" replace;
run;
quit;

cas mysess terminate;
```

## Check the table in Hadoop

1. With the HDFS Web browser:

Open the DFS browser to (http://10.96.14.73:50070/dfshealth.html)

If you browse in /tmp, you should be able to find your table.

1. With the hadoop command line:

Connect to the intcas01 machine as cloud-user and run the following code :

```sh
sudo su - viyademo01
ssh sashdp01
```

Once connected on teh Hadoop machine, run the command below to list the files in /tmp.

```sh
hadoop fs -ls /tmp
```

Now show the content of the file you've just created:

```sh
hadoop fs -cat /tmp/frarpo_zip.csv
```

Adjust the command to use your own SAS ID.

Finally remove the file:

```sh
hadoop fs -rm -skipTrash /tmp/frarpo_zipcode.csv
```

Adjust the command to use your own SAS ID.

## Configure the ssh key for cas

When an end-user works with CAS from the Visual Interfaces or Studio Enterprise, by default the cas session is started with the cas account.
So it means that the ssh passwordless requirement between CAS nodes and HDFS nodes would apply to the cas account.

In a second scenario where we would like to use the Visual Interfaces or SAS Studio Enterprise to interact  with the remote HDFS cluster, we would need to add the cas account public key in the HDFS nodes.

There is no hands-on for this case.
As each RACE collection deployed has already its own ssh key pairs for the cas account on the cas nodes, It would require to keep on adding new keys in our shared HDFS environment for each of the environments.
