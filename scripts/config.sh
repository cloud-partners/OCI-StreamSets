#!/usr/bin/env bash

public_ip=$(oci-public-ip -j | jq -r '.publicIp')
private_ip=$(hostname -I)

cd ~opc
echo "Downloading streamsets-datacollector-3.12.0-el7-all-rpms.tar with --no-verbose..."
while true; do
  wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 0 --continue --no-verbose \
    https://s3-us-west-2.amazonaws.com/archives.streamsets.com/datacollector/3.12.0/rpm/el7/streamsets-datacollector-3.12.0-el7-all-rpms.tar
  if [ $? = 0 ]; then
    echo "Download sucessful"
    break
  else
    echo "Retrying download after 1s sleep..."
  fi # check return value, break if successful (0)
  sleep 1s
done

tar -xf streamsets-datacollector-3.12.0-el7-all-rpms.tar
cd streamsets-datacollector-3.12.0-el7-all-rpms/
yum localinstall streamsets-datacollector-3.12.0-1.noarch.rpm -y
chown -R sdc:sdc /etc/sdc
mkdir -p /var/lib/sdc-resources
chown -R sdc:sdc  /var/lib/sdc-resources
chown -R sdc:sdc /opt/streamsets-datacollector
echo "Stop firewalld"
systemctl stop firewalld
echo "systemctl is-active firewalld"
systemctl is-active firewalld
echo "Open port 18630"
firewall-offline-cmd --zone=public --add-port=18630/tcp
echo "Enable and start firewalld"
systemctl enable firewalld
systemctl start firewalld

echo "Start sdc service"
systemctl start sdc
echo "The default username and password are admin and admin"
echo "Browse to http://$public_ip:18630/"
