#!/bin/sh -xe

sudo dpkg --add-architecture i386
sudo apt-get update -qq
sudo apt-get install -y --no-install-recommends libuuid1:i386