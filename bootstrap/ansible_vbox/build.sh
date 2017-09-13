#/bin/bash
#
# build chef-bcpc on virtualbox assuming images pre-prepared in the
# images directory
#
# from EVW packer branch
# Source this file at the top of your script when needing VBoxManage
# e.g.,
# source ./virtualbox_env.sh

if [[ -z "$VBM" ]]; then

    if ! command -v VBoxManage >& /dev/null; then
        echo "VBoxManage not found!" >&2
        echo "  Please ensure VirtualBox is installed and VBoxManage is on your system PATH." >&2
        exit 1
    fi

    function check_version {
        local MIN_MAJOR=5
        local MIN_MINOR=1

        local IFS='.'
        local version="$(VBoxManage --version)"
        local version_array
        read -a version_array <<< "$version"

        if ! [[ "${version_array[0]}" -ge "$MIN_MAJOR" && \
                "${version_array[1]}" -ge "$MIN_MINOR" ]]
        then
            echo "ERROR: VirtualBox $version is less than $MIN_MAJOR.$MIN_MINOR.x!" >&2
            echo "  Only VirtualBox >= $MIN_MAJOR.$MIN_MINOR.x is officially supported." >&2
            exit 1
        fi
    }

    check_version
    unset -f check_version

    export VBM=VBoxManage
fi


vbm_import() {
    local -r image_name="$1"
    local -r vm_name="$2"
    shift 2
    "$VBM" import "$image_name" --vsys 0 --vmname "$vm_name" "$@"
}

DEPLOYMENT_IMAGE=../../images/build/virtualbox/bcpc-deployment/packer-bcpc-deployment_ubuntu-14.04.2-amd64.ova
BOOTSTRAP_IMAGE=../../images/build/virtualbox/bcpc-bootstrap/packer-bcpc-bootstrap_ubuntu-14.04.2-amd64.ova

vb_nets() {
    local -r vm="$1"
    "$VBM" modifyvm $vm --nic1 nat
    "$VBM" modifyvm $vm --nic2 hostonly --hostonlyadapter2 vboxnet0
    "$VBM" modifyvm $vm --nic3 hostonly --hostonlyadapter3 vboxnet1
    "$VBM" modifyvm $vm --nic4 hostonly --hostonlyadapter4 vboxnet2

}

import_image() {
    local -r img="$1"
    local -r vm="$2"
    if [[ ! -f "${img}" ]]; then
	echo "Can't find $img"
	exit
    fi
    vbm_import $img $vm
    vb_nets $vm
}

#import_image $BOOTSTRAP_IMAGE  bcpc-bootstrap
#import_image $DEPLOYMENT_IMAGE bcpc-deployment

#$VBM startvm bcpc-bootstrap bcpc-deployment

SSHOPTS="-i ../../bootstrap_chef.id_rsa"
SSH="ssh $SSHOPTS"

$SSH  ubuntu@10.0.100.3  "ping -c1 10.0.100.10"
$SSH  ubuntu@10.0.100.10 "ping -c1 10.0.100.3"

$SSH  ubuntu@10.0.100.10 "sudo apt-get -y install git"
$SSH  ubuntu@10.0.100.10 "git clone https://github.com/chef-bcpc.git chef-bcpc"
