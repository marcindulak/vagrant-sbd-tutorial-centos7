# On one of the cluster nodes, authenticate:
vagrant ssh node-1 -c "sudo su - -c 'pcs cluster auth -u hacluster -p password node-1 node-2 node-3'"

# and setup the cluster:
vagrant ssh node-1 -c "sudo su - -c 'pcs cluster setup --name mycluster node-1 node-2 node-3'"
sleep 30
# This configures corosync to use UDP unicast between node-? nodes.

# Start and verify the cluster:
vagrant ssh node-1 -c "sudo su - -c 'pcs cluster start --all'"
sleep 30
vagrant ssh node-1 -c "sudo su - -c 'corosync-cfgtool -s'"
vagrant ssh node-1 -c "sudo su - -c 'pcs status corosync'"
vagrant ssh node-1 -c "sudo su - -c 'pcs status'"
# Note that neither corosync or pacemaker services are enabled to start at boot.

# Test SBD:
vagrant ssh node-1 -c "sudo su - -c 'sbd -d /dev/sdb1 list'"
vagrant ssh node-1 -c "sudo su - -c 'sbd -d /dev/sdb1 dump'"

# Enable stonith:
vagrant ssh node-1 -c "sudo su - -c 'pcs stonith list'"
vagrant ssh node-1 -c "sudo su - -c 'pcs stonith create MyStonith fence_sbd devices=/dev/sdb1 power_timeout=21 action=off'"
vagrant ssh node-1 -c "sudo su - -c 'pcs property set stonith-enabled=true'"
# https://www.suse.com/documentation/sle_ha/book_sleha/data/sec_ha_storage_protect_fencing.html
# Set stonith-timeout to the watchdog msgwait + 20%
# stonith-timeout = Timeout (msgwait) + 20%
vagrant ssh node-1 -c "sudo su - -c 'pcs property set stonith-timeout=24s'"
vagrant ssh node-1 -c "sudo su - -c 'pcs property'"
sleep 30

# Locate the `active` node currently holding the MyStonith resource:
active=`vagrant ssh node-1 -c "sudo su - -c 'crm_resource -r MyStonith query --locate'" | cut -d: -f2 | cut -d'-' -f2 | tr -d '\r'`  # carriage return may pollute here ...
# Select one of the currently passive nodes:
passive=`python -c "import os; print({1: 2, 2: 1, 3: 1}[$active])"`

# Test stonith:
vagrant ssh node-$active -c "sudo su - -c 'uptime'"
vagrant ssh node-$active -c "sudo su - -c 'pcs stonith show MyStonith'"
vagrant ssh node-$active -c "sudo su - -c 'pcs cluster stop node-$active'"  # this should fence node-$active?
sleep 30
vagrant ssh node-$passive -c "sudo su - -c 'pcs status'"
vagrant ssh node-$passive -c "sudo su - -c 'stonith_admin -F node-$active'"  # this too, should fence node-$active
sleep 30
vagrant ssh node-$passive -c "sudo su - -c 'grep stonith-ng /var/log/messages'"
vagrant ssh node-$active -c "sudo su - -c 'sbd -d /dev/sdb1 list'"
vagrant ssh node-$active -c "sudo su - -c 'uptime'"
