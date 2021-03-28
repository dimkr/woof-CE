#!/bin/sh -xe

sudo apt-get update -qq
sudo apt-get install -y --no-install-recommends ccache libelf-dev libssl-dev
ccache --set-config=hash_dir=false --set-config=max_size=2.0G

cd "$1/kernel-kit"
sudo -E ./build.sh "$2"