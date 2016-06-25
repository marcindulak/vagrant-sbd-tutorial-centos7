sudo su - -c "yum -y install wget"
sudo su - -c "wget -q http://vault.centos.org/7.1.1503/os/Source/SPackages/sbd-1.2.1-3.src.rpm -O /root/sbd-1.2.1-3.src.rpm"
sudo su - -c "yum -y install rpm-build"
sudo su - -c "cd /root&& rpm2cpio sbd-1.2.1-3.src.rpm | cpio -idvm"
sudo su - -c "cd /root&& sed -i 's/--disable-shared-disk/--enable-shared-disk/' sbd.spec"
sudo su - -c "yum -y install gcc autoconf automake libuuid-devel glib2-devel libaio-devel corosync-devel pacemaker-libs-devel libtool libxml2-devel python-devel"
sudo su - -c "cd /root&& rpmbuild -ba --define '_sourcedir /root' sbd.spec"

