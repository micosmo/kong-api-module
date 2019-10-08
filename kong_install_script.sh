#!/bin/bash
# Installs, configures and starts kong

yum update -y
yum install -y wget
amazon-linux-extras install -y epel
wget https://bintray.com/kong/kong-rpm/rpm -O bintray-kong-kong-rpm.repo
sed -i -e 's/baseurl.*/&\/amazonlinux\/amazonlinux'/ bintray-kong-kong-rpm.repo
mv bintray-kong-kong-rpm.repo /etc/yum.repos.d/
yum update -y
yum install -y kong

# add file kong.conf to /etc/kong/ - endpoint is needed to be known here

# run kong migrations bootstrap [-c /path/to/kong.conf]
# change permissions to user/kong for your user to w
# kong start[-c /path/to/kong.conf]