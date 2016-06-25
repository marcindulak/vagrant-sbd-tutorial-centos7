# -*- mode: ruby -*-
# vi: set ft=ruby :

hosts = {
  'node-1' => {'ip' => '192.168.10.11', 'mac' => '080027001011'},
  'node-2' => {'ip' => '192.168.10.12', 'mac' => '080027001012'},
  'node-3' => {'ip' => '192.168.10.13', 'mac' => '080027001013'},
}

Vagrant.configure(2) do |config|
  hosts.keys.sort.each do |host|
    config.vm.define host do |machine|
      machine.vm.box = 'centos/7'
      machine.vm.box_url = 'centos/7'
      machine.vm.synced_folder '.', '/home/vagrant/sync', disabled: false
      machine.vm.network 'private_network', :adapter => 2, ip: hosts[host]['ip'], mac: hosts[host]['mac'], auto_config: false
      machine.vm.provider 'virtualbox' do |v|
        v.memory = 256
        v.cpus = 1
        # disable VBox time synchronization and use ntp
        v.customize ['setextradata', :id, 'VBoxInternal/Devices/VMMDev/0/Config/GetHostTimeDisabled', 1]
        # sdb block device is the SBD (STONITH Block Devices)
        disk ='SBD.vdi'
        if !File.exist?(disk)
          v.customize ['createhd', '--filename', disk, '--size', 4, '--variant', 'Fixed']
          v.customize ['modifyhd', disk, '--type', 'shareable']
        end
        v.customize ['storageattach', :id, '--storagectl', 'IDE Controller', '--port', 0, '--device', 1, '--type', 'hdd', '--medium', disk]
      end
    end
  end
  # disable IPv6 on Linux
  $linux_disable_ipv6 = <<SCRIPT
sysctl -w net.ipv6.conf.default.disable_ipv6=1
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.lo.disable_ipv6=1
SCRIPT
  # setenforce 0
  $setenforce_0 = <<SCRIPT
if test `getenforce` = 'Enforcing'; then setenforce 0; fi
#sed -Ei 's/^SELINUX=.*/SELINUX=Permissive/' /etc/selinux/config
SCRIPT
  # common settings on all machines
  $etc_hosts = <<SCRIPT
echo "$*" >> /etc/hosts
SCRIPT
  # configure the second vagrant eth interface
  $ifcfg = <<SCRIPT
IPADDR=$1
NETMASK=$2
DEVICE=$3
TYPE=$4
cat <<END >> /etc/sysconfig/network-scripts/ifcfg-$DEVICE
NM_CONTROLLED=no
BOOTPROTO=none
ONBOOT=yes
IPADDR=$IPADDR
NETMASK=$NETMASK
DEVICE=$DEVICE
PEERDNS=no
TYPE=$TYPE
END
ARPCHECK=no /sbin/ifup $DEVICE 2> /dev/null
SCRIPT
  hosts.keys.sort.each do |host|
    config.vm.define host do |machine|
      machine.vm.provision :shell, :inline => 'hostname ' + host, run: 'always'
      hosts.keys.sort.each do |k|
        machine.vm.provision 'shell' do |s|
          s.inline = $etc_hosts
          s.args   = [hosts[k]['ip'], k]
        end
      end
      machine.vm.provision :shell, :inline => $setenforce_0, run: 'always'
      machine.vm.provision :file, source: '~/.vagrant.d/insecure_private_key', destination: '~vagrant/.ssh/id_rsa'
      machine.vm.provision 'shell' do |s|
        s.inline = $ifcfg
        s.args   = [hosts[host]['ip'], '255.255.255.0', 'eth1', 'Ethernet']
      end
      machine.vm.provision :shell, :inline => $linux_disable_ipv6, run: 'always'
      machine.vm.provision :shell, :inline => 'ifup eth1', run: 'always'
      # restarting network fixes RTNETLINK answers: File exists
      machine.vm.provision :shell, :inline => 'systemctl restart network'
      # install and enable ntp
      machine.vm.provision :shell, :inline => 'yum -y install ntp'
      machine.vm.provision :shell, :inline => 'systemctl enable ntpd'
      machine.vm.provision :shell, :inline => 'systemctl start ntpd'
      # tools
      machine.vm.provision :shell, :inline => 'yum -y install net-tools bind-tools tcpdump curl'
      machine.vm.provision "shell", path: "pcs_install_and_configure.sh"
      machine.vm.provision "shell", path: "sbd_build.sh"
      machine.vm.provision "shell", path: "createrepo.sh"
      machine.vm.provision "shell", path: "sbd_configure.sh"
      machine.vm.provision "shell", path: "fence-agents_build.sh"
      machine.vm.provision "shell", path: "createrepo.sh"
      machine.vm.provision "shell", path: "fence-agents-sbd_install.sh"
      machine.vm.provision :reload
    end
  end
end
