#!/bin/bash

echo "Install Jenkins stable release"
wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
yum upgrade
yum install -y jenkins java-1.8.0-openjdk-devel
systemctl daemon-reload
chkconfig jenkins on

echo "Install Telegraf"
wget https://dl.influxdata.com/telegraf/releases/telegraf-1.6.0-1.x86_64.rpm -O /tmp/telegraf.rpm
yum localinstall -y /tmp/telegraf.rpm
rm /tmp/telegraf.rpm
chkconfig telegraf on
mv /tmp/telegraf.conf /etc/telegraf/telegraf.conf
service telegraf start

echo "Install git"
yum install -y git
cd /var/lib/jenkins
sudo -H -u jenkins bash -c 'git init'
sudo -H -u jenkins bash -c 'git clean -df'

echo "Setup SSH key"
mkdir /var/lib/jenkins/.ssh
touch /var/lib/jenkins/.ssh/known_hosts
chmod 700 /var/lib/jenkins/.ssh
cp /tmp/id_rsa /var/lib/jenkins/.ssh/id_rsa && chown jenkins:jenkins /tmp/id_rsa
mv /tmp/id_rsa.pub /var/lib/jenkins/.ssh/id_rsa.pub
chown -R jenkins:jenkins /var/lib/jenkins/.ssh
chmod 600 /var/lib/jenkins/.ssh/id_rsa /var/lib/jenkins/.ssh/id_rsa.pub

echo "Restore config from git"
sudo -H -u jenkins bash -c 'git remote add origin git@github.com:bw-robotics/JenkinsBackup.git'
sudo -H -u jenkins bash -c 'ssh -o StrictHostKeyChecking=no git@github.com'
sudo -H -u jenkins bash -c 'git pull origin master'

echo "Configure Jenkins"
mkdir -p /var/lib/jenkins/init.groovy.d
mv /tmp/basic-security.groovy /var/lib/jenkins/init.groovy.d/basic-security.groovy
mv /tmp/disable-cli.groovy /var/lib/jenkins/init.groovy.d/disable-cli.groovy
mv /tmp/csrf-protection.groovy /var/lib/jenkins/init.groovy.d/csrf-protection.groovy
mv /tmp/disable-jnlp.groovy /var/lib/jenkins/init.groovy.d/disable-jnlp.groovy
mv /tmp/node-agent.groovy /var/lib/jenkins/init.groovy.d/node-agent.groovy
mv /tmp/jenkins /etc/sysconfig/jenkins
chmod +x /tmp/install-plugins.sh
bash /tmp/install-plugins.sh
service jenkins start