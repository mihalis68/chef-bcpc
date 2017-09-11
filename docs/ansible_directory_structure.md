Ansible directory structure
===

The Ansible build process for chef-bcpc has some required directories
that you must pre-populate with the necessary inputs to a cluster
build before you can use the Ansible playbooks to build a BCPC
cluster.

Ansible scripts
---

Firstly you need a copy of chef-bcpc to get a local copy of the
ansible playbooks that you will invoke to build the cluster. In this
example this will be $HOME/chef-bcpc and we'll call this BCPCDIR

So for example
```
$ cd $HOME
$ git clone https://github.com/chef-bcpc.git chef-bcpc
```

Group Variables
---

The top-level Ansible configuration file for your new cluster is the
`group vars` file which should be created by making a new copy of
$BCPCDIR/bootstrap/ansible_scripts/group_vars/vars.template named
after your cluster so for example

```
cd $HOME
$ cd chef-bcpc/bootstrap/ansible_scripts/group_vars
cp vars.template Test-Laptop-Ansible
```

Apt mirror
---

Apt mirrors are bulky, so the location of your apt mirror is defined
separately from other binaries. The Ansible build path for BCPC
expects to copy an apt mirror to the bootstrap node, since it will
become the apt mirror for the cluster members. Define this location in
your group vars file by setting the controlnode_apt_mirror_dir
variable e.g. in this example edit
~/chef-bcpc/bootstrap/ansible_scripts/group_vars/Test-Laptop-Ansible

Choosing which chef-bcpc files to deploy
---

chef-bcpc can be deployed from a local directory structure (example:
your work in progress based on a clone of chef-bcpc), or from a zip
file such as a chef-bcpc release downloaded from github (see
https://github.com/bloomberg/chef-bcpc/releases). When developing,
deploying from a local copy is very convenient, but when deploying
formal releases (for example to data center clusters) unmodified
releases as zipfiles is cleaner.

In this example we'll deploy chef-bcpc from the chef-bcpc clone
(mentioned above), so uncomment chef_bcpc_deploy_from_dir in your
`group vars` file and set it to $HOME/chef-bcpc.

As an alternative you can specify a different chef-bcpc release
(where?) and the deployment will pick it up from the git-staging
directory (see below). In this case leave chef_bcpc_deploy_from_dir
undefined.


Staging location for other BCC dependencies
---

In addition to the Ansible scripts that build your cluster, you need
to setup a directory structure to contain the non-chef-bcpc files such
as binaries, script files, keys etc to assemble the cluster from.

The root of this directory structure is referred to as your `staging
location` in other documents and is often named bcpc-deployment, so
for this example we'll continue with that convention. If you use a
freshly installed machine (perhaps a VM) as your deployment host (aka
"bastion host") deployment could be from your home directory : in this
example, the staging directory is $HOME/bcpc-deployment.

Binaries will be stored in a subdirectory called git-staging under
your deployment dir.

In addition to containing pre-built bcpc components such the gems and
.deb files from the build, we expect your deployment to have a local
python environment (a "virtualenv") in which the tools to support
Ansible will go. This is in $HOME/bcpc-deployment/bin and
$HOME/bcpc-deployment/include.

A worked example of setting up your staging dir would be

```
$ mkdir ~/bcpc-deployment
$ cd ~/bcpc-deployment
$ mkdir git-staging
$ cd git-staging
$ mkdir bootstrap-files
$ mkdir boostrap-files/master
$ cp -pr $HOME/.bcpc-cache/* bootstrap-files/master
$ pip install virtualenv
$ cd ..
$ virtualenv git-staging
$ cd git-staging
$ source bin/activate .
```







