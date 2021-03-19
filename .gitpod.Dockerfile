FROM gitpod/workspace-full-vnc

RUN sudo apt-get update -qq && apt-get install --no-install-recommends qemu-system-x86_64
