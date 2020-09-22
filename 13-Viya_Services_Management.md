# Viya Services management

* [Checking up on the status of services](#checking-up-on-the-status-of-services)
* [Starting/Stopping all the services on all the machines](#startingstopping-all-the-services-on-all-the-machines)
* [Disable auto start of the Viya Services](#disable-auto-start-of-the-viya-services)
* [Turn off SAS Studio Basic](#turn-off-sas-studio-basic)
* [(Optional) Manage your Viya Services with Viya ARK](#optional-manage-your-viya-services-with-viya-ark)
* [(Optional) restart Viya services individually](#optional-restart-viya-services-individually)

## Checking up on the status of services

* Run the code below to get the Viya services status from each machine (call the default services script on each machine).

    ```bash
    cd ~/sas_viya_playbook
    # check the service status.
    ansible sas_all -b -m shell -a "/etc/init.d/sas-viya-all-services status"
    ```

All services should report 'up' Status. If any do not, this is something that must be investigated.

## Starting/Stopping all the services on all the machines

A **WRONG** way to stop all the services would be to run:

```sh
cd ~/sas_viya_playbook

# stop all services
#ansible sas_all -b -m shell -a "/etc/init.d/sas-viya-all-services stop"
```

And identically, to start it up:

```sh
cd ~/sas_viya_playbook

# start all services
#ansible sas_all -b -m shell -a "/etc/init.d/sas-viya-all-services start"
```

**DO NOT USE THESE COMMANDS in multi-machines deployments; services would start/stop in the wrong sequence.**
The correct commands are below.

## Disable auto start of the Viya Services

In multi-machines deployments (especially when Viya supporting services are spread across multiple hosts), it could be a good idea to disable the automatic startup of the Viya services.

If you leave them in "autostart" configuration, when your machines reboot you might experience some issues because of the dependencies between them.

* Check the state of the "sas-viya-all-services" service across the SAS Viya Servers:

    ```sh
    ansible sas_all -b -m shell -a "systemctl list-unit-files | grep sas-viya-all-services"
    ```

* If the service is "enabled", then disable the auto start of the Viya services:

    ```bash
    ansible sas_all -m service -a "name=sas-viya-all-services.service enabled=no" -b
    ```

## Turn off SAS Studio Basic

The official documentation states clearly that Studio (Basic) is intended for programming-only while Studio (Enterprise) is for full deployments.
Now that we have functional parity, we don't have to keep the "SAS Studio (Basic)" service running in a Full Viya deployment.

* So let's disable the service.

    ```bash
    # disable SAS Studio Basic service
    ansible programming -m service -a "name=sas-viya-sasstudio-default state=stopped enabled=no" -b
    ```

* Add sas-viya-sasstudio-default to "/opt/sas/viya/config/etc/viya-svc-mgr/svc-ignore" so sas-viya-all-services will ignore it.

    ```bash
    ansible programming -m shell -a "echo 'sas-viya-sasstudio-default' >> /opt/sas/viya/config/etc/viya-svc-mgr/svc-ignore" -b
    ```

## (Optional) Manage your Viya Services with Viya ARK

If you have the Viya-ARK viya-services-* scripts in your "sas_viya_playbook" folder, you can use the Viya-ARK multi-machine services management scripts.

* To check the status of the services accross the machines:

    ```bash
    cd ~/sas_viya_playbook
    ansible-playbook viya-ark/playbooks/viya-mmsu/viya-services-status.yml
    ```

**UNLESS NECCESSARY OR ASKED BY THE TEACHER DO NOT USE THE COMMANDS BELOW TO START/STOP THE SERVICES. RESTARTING THE SERVICES CAN TAKE ALMOST AN HOUR.**

* To start everything:

    ```sh
    cd ~/sas_viya_playbook
    ansible-playbook viya-ark/playbooks/viya-mmsu/viya-services-start.yml
    ```

* To restart everything:

    ```sh
    cd ~/sas_viya_playbook
    ansible-playbook viya-ark/playbooks/viya-mmsu/viya-services-restart.yml
    ```

* To stop everything:

    ```sh
    cd ~/sas_viya_playbook
    ansible-playbook viya-ark/playbooks/viya-mmsu/viya-services-stop.yml
    ```

* To stop everything and remove stray processes:

    ```sh
    cd ~/sas_viya_playbook
    ansible-playbook viya-ark/playbooks/viya-mmsu/viya-services-stop.yml -e "enable_stray_cleanup=true"
    ```

## (Optional) restart Viya services individually

As many services are starting about the same time, it is possible (and even likely) that, at some point the servers were overloaded and that some individual Microservices were not able to register correctly in Consul. They would report a "down" or "not ready status".

In such case, a proven practice is to simply shutdown and restart individually each service in this state.
As our environment is under CentOS 7.6, we use the systemctl command:

```sh
sudo systemctl stop <viya service>
#wait 2-3 sec
sudo systemctl start <viya service>
#wait 2-3 sec
sudo systemctl status <viya service>
```

To save some time, if there are many services in this situation, you can use a text editor to build a multi-lines command with "sleep" commands between each stop and start and run it at once.

Then, wait a little bit and the /etc/init.d/sas-viya-all-services should report that all the services are up and running.
