#!/usr/bin/env bash

public_ip=$(oci-public-ip -j | jq -r '.publicIp')
private_ip=$(hostname -I)

wget https://s3-us-west-2.amazonaws.com/archives.streamsets.com/datacollector/3.12.0/rpm/el7/streamsets-datacollector-3.12.0-el7-all-rpms.tar
tar -xf streamsets-datacollector-3.12.0-el7-all-rpms.tar
cd streamsets-datacollector-3.12.0-el7-all-rpms/
sudo yum localinstall streamsets-datacollector-3.12.0-1.noarch.rpm -y
sudo chown -R sdc:sdc /etc/sdc
sudo mkdir -p /var/lib/sdc-resources
sudo chown -R sdc:sdc  /var/lib/sdc-resources
sudo chown -R sdc:sdc /opt/streamsets-datacollector
sudo firewall-cmd --zone=public --add-port=18630/tcp --permanent
sudo systemctl restart firewalld
sudo systemctl start sdc
echo The default username and password are admin and admin
echo Browse to http://${data.oci_core_vnic.datacollector_vnic.public_ip_address}:18630/
