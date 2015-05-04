#! /bin/bash

# Bring up eth0
ifup eth0

# Install packages
yum install -y openssh-clients man git vim wget curl ntp postfix

# Install server stack
yum install -y httpd php php-mysql php-imap php-pdo php-cli php-fpm php-gd php-intl php-xml php-proxess php-xmlrpc php-zts php-devel mysql-server 

# Restart Apache and Mysql
service httpd restart
service mysqld start

# Finish Mysql install
# This will prompt to set root password
/usr/bin/mysql_secure_installation

# Install Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/bin/composer

# Enable RPMforge repo and install dkms
yum --enablerepo rpmforge install dkms

# Install dev environment and kernel source
yum groupinstall "Development Tools"
yum install kernel-devel

# Enable ntpd
chkconfig ntpd on

# Set time
service ntpd stop
ntpdate time.nist.gov
service ntpd start

# Enable SSh on startup
chkconfig sshd on

#Disable Firewalls (Centos 6.6 and below)
chkconfig iptables off
chkconfig ip6tables off

# Set SELinux to permissive
sed -i -e 's/^SELINUX=.*/SELINUX=permissive/' /etc/selinux/config

# Add vagrant user
useradd vagrant

# Create Vagrant users .ssh directory, add insecure keyset, and set proper permissions
mkdir -m 0700 -p /home/vagrant/.ssh
curl https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub >> /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# Comment out requiretty in sudoers to allow ssh to send remote sudo commands
sed -i 's/^\(Defaults.*requiretty\)/#\1/' /etc/sudoers

# Passwordless sudo
echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Remove udev persistent net rules file
rm -f /etc/udev/rules.d/70-persistent-net.rules

echo "Finished. Please edit /etc/sysconfig/network-scripts/ifcfg-eth0 to reflect the following: \n
DEVICE=eth0 \n
TYPE=Ethernet \n
ONBOOT=yes \n
NM_CONTROLLED=no \n
BOOTPROTO=dhcp \n
And run the shrink_box script"
