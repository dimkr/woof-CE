#!/bin/sh -xe

curl https://raw.githubusercontent.com/puppylinux-woof-CE/initrd_progs/master/pkg/w_apps_static/w_apps/vercmp.c | gcc -x c -o /tmp/vercmp -
sudo install -m 755 /tmp/vercmp /usr/local/bin/vercmp
sudo install -D -m 644 woof-code/rootfs-skeleton/usr/local/petget/categories.dat /usr/local/petget/categories.dat
echo "dash dash/sh boolean false" | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash
sudo ln -s bash /bin/ash