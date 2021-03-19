FROM gitpod/workspace-full-vnc:latest

RUN sudo apt-get update -qq && sudo apt-get install -y --no-install-recommends matchbox twm qemu-system-x86 fakeroot
RUN curl https://raw.githubusercontent.com/puppylinux-woof-CE/initrd_progs/master/pkg/w_apps_static/w_apps/vercmp.c | sudo gcc -x c -o /usr/local/bin/vercmp -
RUN sudo mkdir -p /usr/local/petget && curl https://raw.githubusercontent.com/puppylinux-woof-CE/woof-CE/testing/woof-code/rootfs-skeleton/usr/local/petget/categories.dat | sudo tee /usr/local/petget/categories.dat
RUN echo "dash dash/sh boolean false" | sudo debconf-set-selections && sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash
