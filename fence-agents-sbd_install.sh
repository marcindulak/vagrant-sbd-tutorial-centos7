sudo su - -c "yum clean all"
sudo su - -c "yum -y install yum-plugin-versionlock"
sudo su - -c "yum -y install fence-agents-common fence-agents-sbd"
sudo su - -c "yum versionlock add fence-agents-*"
