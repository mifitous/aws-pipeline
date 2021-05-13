#!/bin/bash

uname -m
uname -r

echo "add swapfile"
dd if=/dev/zero of=/swapfile bs=128M count=32
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
swapon -s
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

echo "Install Docker engine"
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io
groupadd docker
usermod -aG docker ubuntu
service docker start
systemctl enable docker.service
systemctl enable containerd.service
systemctl restart docker.service

echo "Install Java JDK 8"
apt-get update -y
apt-get install -y openjdk-8-jdk

echo "Install git"
apt-get install -y git

echo "Install Telegraf"
wget -qO- https://repos.influxdata.com/influxdb.key | apt-key add -
. /etc/lsb-release
echo "deb https://repos.influxdata.com/ubuntu bionic stable"
echo "deb https://repos.influxdata.com/ubuntu bionic stable" | tee /etc/apt/sources.list.d/influxdb.list
apt-get update -y && apt-get install -y telegraf
usermod -aG docker telegraf
mv /tmp/telegraf.conf /etc/telegraf/telegraf.conf
systemctl enable --now telegraf
systemctl is-enabled telegraf
service telegraf start
systemctl status telegraf
