
#!/bin/sh -ex

(
    sleep 360
    echo screendump /tmp/quicksetup.pnm

    echo sendkey alt-f4
    sleep 10
    echo screendump /tmp/welcome1stboot.pnm

    echo sendkey alt-f4
    sleep 2
    echo screendump /tmp/desktop.pnm

    echo quit

) | qemu-system-x86_64 -m 512 -drive format=raw,file=$1 -display none -monitor stdio -vga cirrus

for SHOT in quicksetup welcome1stboot desktop; do
    convert ${SHOT}.pnm /tmp/${SHOT}.bmp
    composite -compose atop mask.xpm /tmp/${SHOT}.pnm /tmp/${SHOT}-masked.bmp
    cmp /tmp/${SHOT}.bmp /tmp/${SHOT}-masked.bmp
done