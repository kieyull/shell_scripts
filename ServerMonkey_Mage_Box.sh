#!/bin/bash

#Vagrant requires password-less sudo
echo 'vagrant         ALL=(ALL)       NOPASSWD: ALL' >> /etc/sudoers

#Set insecure keys
vssh="/home/${account}/.ssh"
mkdir -p $vssh
chmod 700 $vssh
(cd $vssh &&
  wget --no-check-certificate \
    'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' \
    -O $vssh/authorized_keys)
chmod 0600 $vssh/authorized_keys
chown -R ${account}:vagrant $vssh
unset vssh

#update
yum update -y

#Install required guest additions
yum install -y dkms binutils gcc make patch libgomp glibc-headers glibc-devel kernel-headers kernel-devel

#Add Repositories to install PHP 5.5
rpm -Uvh https://mirror.webtatic.com/yum/el7/epel-release.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

#Install dev additions
yum install -y apache2 mysql-server php55w php55w-common php55w-mysql 

#Install tools
yum install -y vim-enhanced nano git 

