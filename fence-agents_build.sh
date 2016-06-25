sudo su - -c "yum -y install wget"
sudo su - -c "wget -q http://dl.fedoraproject.org/pub/fedora/linux/releases/24/Everything/source/tree/Packages/f/fence-agents-4.0.20-2.fc24.src.rpm -O /root/fence-agents-4.0.20-2.fc24.src.rpm"
sudo su - -c "yum -y install rpm-build"
sudo su - -c "cd /root&& rpm2cpio fence-agents-4.0.20-2.fc24.src.rpm | cpio -idvm"

# sbd agent has been added on Sep 24, 2015 https://github.com/ClusterLabs/fence-agents/commit/91314f33519ba5498afb2ba6da9eca30381b263e#diff-8efbbedefcc057f63953b9db37fbd163
sudo su - -c "cd /root&& wget -q https://github.com/ClusterLabs/fence-agents/archive/v4.0.22.tar.gz -O fence-agents-4.0.22.tar.gz"
# sbd agent patched on Jun 16, 2016 https://github.com/ClusterLabs/fence-agents/commit/ae4f9ccd4102f838b4c97944e2d66e543a1ec5f8#diff-8efbbedefcc057f63953b9db37fbd163
sudo su - -c "cd /root&& tar zxf fence-agents-4.0.22.tar.gz&& mv fence-agents-4.0.22.tar.gz fence-agents-4.0.22.tar.gz.orig"
sudo su - -c "cd /root&& cd fence-agents-4.0.22/fence/agents/sbd&& rm -f fence_sbd.py&& wget -q https://raw.githubusercontent.com/ClusterLabs/fence-agents/ae4f9ccd4102f838b4c97944e2d66e543a1ec5f8/fence/agents/sbd/fence_sbd.py&& sed -i 's|@PYTHON@|/usr/bin/python|' fence_sbd.py"
sudo su - -c "cd /root&& tar zcf fence-agents-4.0.22.tar.gz fence-agents-4.0.22"

sudo su - -c "yum -y install gnutls-utils pexpect python-suds python-requests"
sudo su - -c "yum -y install patch"
sudo su - -c "cd /root&&patch -p0 < /home/vagrant/sync/fence-agents.spec.patch"
sudo su - -c "cd /root&& rpmbuild -ba --define '_sourcedir /root' fence-agents.spec"

