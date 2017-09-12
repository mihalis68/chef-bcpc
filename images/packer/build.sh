#!/bin/bash
set -e
rm -rf ../build
.//build-bootstrap.sh
./build-deployment.sh
