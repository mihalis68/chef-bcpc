#!/bin/bash
keyfile="deployment.id_rsa"
rm "${keyfile}"*
ssh-keygen -N "" -f "$keyfile"
cp "${keyfile}".pub files
cp "${keyfile}" ../..

packer build bcpc-deployment.json
# packer build bcpc-bootstrap-output.json
