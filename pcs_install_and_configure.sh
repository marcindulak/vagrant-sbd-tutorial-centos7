# http://clusterlabs.org/doc/en-US/Pacemaker/1.1-pcs/html/Clusters_from_Scratch/_install_the_cluster_software.html
sudo su - -c "yum -y install pacemaker pcs psmisc policycoreutils-python"
sudo su - -c "firewall-cmd --permanent --add-service=high-availability"
sudo su - -c "firewall-cmd --reload"
sudo su - -c "systemctl start pcsd.service"
sudo su - -c "systemctl enable pcsd.service"
sudo su - -c "echo password | passwd --stdin hacluster"
