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

if [[ ! -f "${DEPLOYMENT_IMAGE}" ]]; then
    echo "Can't find $DEPLOYMENT_IMAGE"
    exit
fi
vbm_import "$DEPLOYMENT_IMAGE" bcpc-deployment
if [[ ! -f "${BOOTSTRAP_IMAGE}" ]]; then
    echo "Can't find $BOOTSTRAP_IMAGE"
    exit
fi
vbm_import "$BOOTSTRAP_IMAGE" bcpc-bootstrap
