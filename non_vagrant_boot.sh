#/bin/sh
#
# A utility to take some of the manual labor out of the non-Vagrant
# based chef-bcpc bringup procedure on VMs
# 


# bash imports
source ./virtualbox_env.sh

SSHCOMMON="-q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o VerifyHostKeyDNS=no -i bootstrap_chef.id_rsa"
SSHCMD="ssh $SSHCOMMON"
SCPCMD="scp $SSHCOMMON"

if [[ -z `VBoxManage list vms` ]]; then
    echo "No VMs exist, please run vbox_create.sh first"
    exit
fi

UP=`$VBM showvminfo bcpc-bootstrap | grep -i State`
if [[ ! $UP =~ running ]]; then
    $VBM startvm bcpc-bootstrap
else
    echo "bcpc-bootstrap is running"
fi
sleep 20
#set -x
HOST=10.0.100.3
UP=`fping -aq 10.0.100.3 | awk '{print $1}'`
if [[ ! -z "$UP" ]]; then
    # bootstrap node do
    BNDO="$SSHCMD  ubuntu@10.0.100.3"
    NAME=`$BNDO "hostname"`
    if [[ "$NAME" =~ bcpc-bootstrap ]]; then
	EDITED=`$BNDO "echo ubuntu | sudo -S grep 'Static interfaces' /etc/network/interfaces"`
	echo "EDITED = $EDITED"
	if [[ "$EDITED" =~ "Static interfaces" ]]; then
	    echo "interfaces file appears adjusted already"
	else
	    echo "copy interfaces file fragment..."
	    $SCPCMD -p "vm-eth.txt" "ubuntu@$HOST:/tmp"
	    echo "add the network definitions"
            # can't simply cat file >> file when updating the interfaces, due to the permissions
            # rename does work to atomically replace the file
	    $BNDO "echo ubuntu | sudo -S cp -p /etc/network/interfaces /etc/network/interfaces.orig"
	    $BNDO "echo ubuntu | sudo -S cat /etc/network/interfaces /tmp/vm-eth.txt > /tmp/combined.txt"
	    $BNDO "echo ubuntu | sudo -S mv /tmp/combined.txt /etc/network/interfaces"
	    echo "restart networking"
	    $BNDO "echo ubuntu | sudo -S service networking restart"
	fi
        echo "Hurrah!"
	
	BOOTDONE=`$BNDO "ls -l /var/www/cobbler/pub/keys/root | grep rwxr"`
	if [[ -z "$BOOTDONE" ]]; then
	    ./bootstrap_chef.sh ubuntu 10.0.100.3 Test-Laptop
	fi
	COBBLERDONE=`$BNDO "sudo cobbler system list | grep bcpc-vm3"`
	if [[ -z "$COBBLERDONE" ]]; then
	    ./enroll_cobbler.sh 10.0.100.3 start
	    sleep 240
	    while true 
	    do
                RES=`./vm-to-cluster.sh local.lan Test-Laptop`
                if [[ ! ${RES} =~ "FAILED" ]]; then
		    break;
                else
		    sleep 10
                fi
	    done
	fi
        $BNDO "cd chef-bcpc && ./cluster-assign-roles.sh Test-Laptop"
        $BNDO "cd chef-bcpc && ./cluster-rechef.sh Test-Laptop"
        KEYSTONE=`$BNDO "cd chef-bcpc && knife data bag show configs Test-Laptop | grep -i keystone-admin-password"`
        KEYSTONE=`echo $KEYSTONE | awk '{print $2}'`
        echo "your Horizon password is: $KEYSTONE"
        exit 0
    fi
fi
