# https://www.suse.com/documentation/sle_ha/book_sleha/data/sec_ha_storage_protect_fencing.html
sudo su - -c "yum clean all"
sudo su - -c "yum -y install yum-plugin-versionlock"
sudo su - -c "yum -y install sbd-1.2.1-3.x86_64"
sudo su - -c "yum versionlock add sbd"
sudo su - -c "parted --script /dev/sdb mklabel msdos mkpart primary 1 100%"
# create SBD device with increased latency thresholds (avoid "Latency: 4 exceeded threshold 3 on disk")
# https://www.novell.com/support/kb/doc.php?id=7011350
sudo su - -c "sbd -d /dev/sdb1 -4 20 -1 10 create"  # the default is "-4 10 -1 5"
sudo su - -c "sbd -d /dev/sdb1 dump"
sudo su - -c "echo SBD_DEVICE=\\\"/dev/sdb1\\\" >> /etc/sysconfig/sbd"
sudo su - -c "sed -i '/SBD_OPTS/d' /etc/sysconfig/sbd"
# https://www.novell.com/support/kb/doc.php?id=7009485 - passing option '-W' to the sbd. It will then  be started if openais is started
# https://www.amazon.com/Pro-Linux-High-Availability-Clustering/dp/1484200802 - uses '-W -P'
sudo su - -c "echo SBD_OPTS=\\\"-W -P\\\" >> /etc/sysconfig/sbd"
# http://blog.clusterlabs.org/blog/2015/sbd-fun-and-profit - SBD is automatically started and stopped whenever corosync is
sudo su - -c "systemctl enable sbd"
sudo su - -c "yum -y install watchdog"
# load softdog at boot
sudo su - -c "echo softdog > /etc/modules-load.d/softdog.conf"
sudo su - -c "modprobe softdog"
