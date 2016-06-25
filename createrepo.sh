sudo su - -c "yum clean all"
sudo su - -c "yum -y install createrepo"
export rpmbuild=`readlink -f /root/rpmbuild/RPMS`
sudo su - -c "createrepo ${rpmbuild}"
sudo su - -c "cat <<END > /etc/yum.repos.d/ss5.repo
[ss5]
name=CentOS-$releasever - ss5 locally built RPMS
baseurl=file://${rpmbuild}
enabled=1
gpgcheck=0
END"
