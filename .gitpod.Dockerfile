FROM gitpod/workspace-full-vnc

RUN sudo apt-get update -qq && sudo apt-get install --no-install-recommends qemu-system-x86
