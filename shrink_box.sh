#!/bin/bash

# Remove Yum cache
echo "Cleaning Yum"
yum clean all

# Zero free space to aid VM compression
echo "Zero free space to aid VM compression"
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Remove Virtualbox specific files
echo "Removing Virtualbox specific files"
rm -rf /usr/src/vboxguest* /usr/src/virtualbox-ose-guest*

# Remove bash history
echo "Removing bash history"
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/vagrant/.bash_history

# Cleanup log files
echo "Cleanup log files"
find /var/log -type f | while read f; do echo -ne '' > $f; done;
echo "Cleaning /tmp"
rm -rf /tmp/*
echo "Cleaning /var/log/wtmp"
rm -f /var/log/wtmp
echo "Cleaning /var/log/btmp"
rm -f /var/log/btmp
echo "Cleaning bash history"
history -c

# Whiteout root
echo "Whiteout root"
count=`df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}'`;
count=$((count -= 1))
dd if=/dev/zero of=/tmp/whitespace bs=1024 count=$count;
rm /tmp/whitespace;

# Whiteout /boot
echo "Whiteout /boot"
count=`df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}'`;
count=$((count -= 1))
dd if=/dev/zero of=/boot/whitespace bs=1024 count=$count;
rm /boot/whitespace;

# Whiteout swap
echo "Whiteout swap"
swappart=`cat /proc/swaps | tail -n1 | awk -F ' ' '{print $1}'`
swapoff $swappart;
dd if=/dev/zero of=$swappart;
mkswap $swappart;
swapon $swappart;

echo " "
echo " "
echo " "

echo "Shutdown now? (y/n)"
read ANSWER
if [ "$ANSWER" = "y" ]; then
echo "Shutting down"
shutdown -h now
else
echo "Not Shutting down"
fi

