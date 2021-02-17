#!/bin/bash -ex

command_qemu() {
    echo "$1" >> /tmp/qemu.in
}

wait_for_screenshot() {
    started=0
    for i in `seq 1 $1`; do
        echo $i 1>&2
        command_qemu "screendump /tmp/$2.pnm"
        sleep 1
        composite -compose atop mask.xpm /tmp/$2.pnm /tmp/$2-masked.bmp
        cmp /tmp/$2.bmp /tmp/$2-masked.bmp > /dev/null || continue
        started=1
        break
    done
    test $started -eq 1
}

[ -p /tmp/qemu.in ] || mkfifo /tmp/qemu.in
[ -p /tmp/qemu.out ] || mkfifo /tmp/qemu.out

if [ -n "$GITHUB_ACTIONS" ]; then
    qemu-system-x86_64 -m 512 -drive format=raw,file=$1 -monitor pipe:/tmp/qemu -vga cirrus -display none &
else
    qemu-system-x86_64 -m 512 -drive format=raw,file=$1 -monitor pipe:/tmp/qemu -vga cirrus &
fi

for SHOT in *.pnm; do
    convert ${SHOT} /tmp/${SHOT%.pnm}.bmp
done

# wait until the desktop is ready
wait_for_screenshot 360 quicksetup

command_qemu "sendkey alt-f4"
wait_for_screenshot 10 welcome1stboot

command_qemu "sendkey alt-f4"
wait_for_screenshot 5 desktop

command_qemu "sendkey ctrl-alt-t"
wait_for_screenshot 10 terminal

command_qemu quit