#!/bin/bash

USER_NAME=$1

APP_DIR="/home/${USER_NAME}/app"

mkdir -p ${APP_DIR}

pushd ${APP_DIR}

# install go

# git clone the cni repos
git clone https://github.com/containernetworking/cni.git

cd cni

# build the cnitool and plugins ...

. ./scripts/release.sh

# ....

popd
