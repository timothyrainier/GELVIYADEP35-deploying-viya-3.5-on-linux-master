# Deploying Viya 3.5 on Linux

This project contains the Hands-on for the VLE "Deploying Viya 3.5"

* [00 HouseKeeping](00-HouseKeeping.md)
* [01 Hardware Reservation based on profile](01-Hardware_Reservation_based_on_profile.md)
* [02 Creating an order](02-Creating_an_order.md)
* [03 Connecting to the environment](03-Connecting_to_the_environment.md)
* [04 YUM and RPM](04-YUM_and_RPM.md)
* [05 Installing Ansible on SASVIYA01](05-Installing_Ansible_on_SASVIYA01.md)
* [06 Configuring Ansible to target the servers](06-Configuring_Ansible_to_target_the_servers.md)
* [07 Building your deployment playbook](07-Building_your_deployment_playbook.md)
* [08 Mirror Creation](08-Mirror_Creation.md)
* [09 Performing the pre-requisites](09-Performing_the_pre-requisites.md)
* [10 OpenLDAP deployment](10-OpenLDAP_deployment.md)
* [11 Playbook upload and prep](11-Playbook_upload_and_prep.md)
* [12 Split Deployment](12-Split_Deployment.md)
* [13 Viya Services Management](13-Viya_Services_Management.md)
* [14 Validation](14-Validation.md)
* [15 Add a new CAS Server](15-Add_a_new_CAS_Server.md)
* [16 HA Deployment](16-HA_Deployment.md)
* [17 Post-install activities](17-Post-install_activities.md)
* [18 Update your order with a new product](18-Update_your_order_with_a_new_product.md)
* [19 Configure Data connector to access Hive](19-Configure_Data_connector_to_access_Hive.md)
* [20 Creating a new account for Viya deployment](20-Creating_a_new_account_for_Viya_deployment.md)
* [21 Jupyter Hub](21-Jupyter_Hub.md)
* [22 Configure remote HDFS Access](22-Configure_remote_HDFS_Access.md)
* [23 1-FullSplit Deployment](23-1-FullSplit_Deployment.md)
* [23 2-Configure local HDFS](23-2-Configure_local_HDFS.md)


<!--
to re-generate the list
```sh
for f in *.md   ; do

    #echo  "$f"
    f2=$(echo "$f" | sed 's/\-/\ /' | sed 's/\_/\ /g' | sed 's/\.md//')
    #echo $f2
    printf "\n* [$f2]($f)"

done
```
-->
