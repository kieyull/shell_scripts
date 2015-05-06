#! /bin/bash

# Install packages
yum install -y openssh-clients man vim wget curl ntp postfix

# Install Epel and IUS repos for newer php versions
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -Uvh epel-release-6*.rpm

wget http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/ius-release-1.0-13.ius.centos6.noarch.rpm
rpm -Uvh ius-release*.rpm

# Install server stack
yum install -y httpd php55u php55u-mysql php55u-imap php55u-pdo php55u-cli php55u-fpm php55u-gd php55u-intl php55u-xml php55u-proxess php55u-xmlrpc php55u-zts php55u-devel mysql-server

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
echo "vagrant" | passwd vagrant --stdin

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

# Set eth0 device to start on boot
sed 's/ONBOOT=no/ONBOOT=yes' /etc/sysconfig/network-scripts/ifcfg-eth0

echo "Finished."
