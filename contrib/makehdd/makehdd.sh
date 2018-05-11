#!/bin/sh

DEV=/dev/vda
MNT=/mnt/vda1

(echo n; echo p; echo 1; echo; echo; echo w) | fdisk ${DEV}
until [ -b "${DEV}1" ]; do
  sleep 0.5
done
mkfs.ext4 -b 4096 -i 4096 -F -L BARGE-DATA ${DEV}1

mkdir -p ${MNT}
mount -t ext4 ${DEV}1 ${MNT}

mkdir -p ${MNT}/etc
mkdir -p ${MNT}/work/etc
mount -t overlay overlay -o lowerdir=/etc,upperdir=${MNT}/etc,workdir=${MNT}/work/etc /etc

mkdir -p /etc/default
wget -qO /etc/default/docker https://raw.githubusercontent.com/imjching/wharfkit-barge-xhyve/master/contrib/configs/profile
wget -qO /etc/init.d/start.sh https://raw.githubusercontent.com/imjching/wharfkit-barge-xhyve/master/contrib/configs/start.sh
chmod +x /etc/init.d/start.sh
wget -qO /etc/init.d/init.sh https://raw.githubusercontent.com/imjching/wharfkit-barge-xhyve/master/contrib/configs/init.sh
chmod +x /etc/init.d/init.sh

passwd -d bargee
sed -i '/PermitEmptyPasswords/s/no/yes/' /etc/ssh/sshd_config
sed -i '/PermitEmptyPasswords/s/^#//' /etc/ssh/sshd_config

sync; sync; sync
