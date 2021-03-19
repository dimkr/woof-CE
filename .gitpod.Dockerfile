FROM gitpod/workspace-full-vnc

RUN sudo apt-get update -qq && apt-get install --no-install-recommnds qemu-system-x86_64
