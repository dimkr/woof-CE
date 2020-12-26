if [ -z "$WOOF_CFLAGS"]; then
    case "$DISTRO_TARGETARCH" in
    arm) WOOF_CFLAGS="-march=armv7-a -mfpu=neon-vfpv4 -mfloat-abi=hard" ;;
    x86) WOOF_CFLAGS="-march=i486 -mtune=i686" ;;
    x86_64) WOOF_CFLAGS="-march=generic -mtune=generic" ;;
    esac
fi

[ -z "$WOOF_CXXFLAGS"] && WOOF_CXXFLAGS="$WOOF_CFLAGS"

WOOF_CFLAGS="$WOOF_CFLAGS -Os -fomit-frame-pointer -ffunction-sections -fdata-sections -fmerge-all-constants"
WOOF_CXXCFLAGS="$WOOF_CXXCFLAGS -Os -fomit-frame-pointer -ffunction-sections -fdata-sections -fmerge-all-constants"
WOOF_LDFLAGS="$WOOF_LDFLAGS -Wl,--gc-sections -Wl,--sort-common -Wl,-s"
MAKEFLAGS=-j`nproc`

for i in ../rootfs-petbuilds/*; do
    NAME=${i#../rootfs-petbuilds/}
    [ -d "../rootfs-packages/${NAME}" ] && continue
    mkdir -p ../rootfs-packages/${NAME} petbuild-root
    mount -t aufs -o br=../rootfs-packages/${NAME}:devx:rootfs-complete petbuild petbuild-root
    mkdir -p petbuild-root/proc petbuild-root/sys petbuild-root/dev petbuild-root/tmp
    mount --bind /proc petbuild-root/proc
    mount --bind /sys petbuild-root/sys
    mount --bind /dev petbuild-root/dev
    mount --bind /tmp petbuild-root/tmp
    cp -a ../rootfs-petbuilds/${NAME}/* petbuild-root/tmp/
    chroot petbuild-root sh -c "cd /tmp && CFLAGS=\"$WOOF_CFLAGS\" CXXFLAGS=\"$WOOF_CXXFLAGS\" LDFLAGS=\"$WOOF_LDFLAGS\" MAKEFLAGS=\"$MAKEFLAGS\" ./petbuild"
    ret=$?
    umount -l petbuild-root/tmp
    umount -l petbuild-root/dev
    umount -l petbuild-root/sys
    umount -l petbuild-root/proc
    umount -l petbuild-root

    if [ $ret -ne 0 ]; then
        echo "ERROR: failed to build ${NAME}"
        exit 1
    fi

    rm -rf ../rootfs-packages/${NAME}/tmp ../rootfs-packages/${NAME}/usr/share/man ../rootfs-packages/${NAME}/usr/share/info ../rootfs-packages/${NAME}/root/.wget-hsts ../rootfs-packages/${NAME}/usr/share/icons/hicolor/icon-theme.cache
    rmdir ../rootfs-packages/${NAME}/* 2>/dev/null
    find ../rootfs-packages/${NAME} -name '.wh*' -delete
    find ../rootfs-packages/${NAME} -name '.git*' -delete

    find ../rootfs-packages/${NAME} -type f | while read ELF; do
        strip --strip-all -R .note -R .comment ${ELF} 2>/dev/null
    done

    for EXTRAFILE in ../rootfs-petbuilds/${NAME}/*; do
        case "${EXTRAFILE##*/}" in
        petbuild|*.patch) ;;
        *) cp -a $EXTRAFILE ../rootfs-packages/${NAME}/
        esac
    done

    rm -f rootfs-complete/pinstall.sh
    cp -a ../rootfs-packages/${NAME}/* rootfs-complete/
    if [ -f rootfs-complete/pinstall.sh ]; then
        chroot rootfs-complete /pinstall.sh
        rm -f rootfs-complete/pinstall.sh
    fi
    cat ../rootfs-petbuilds/${NAME}/pet.specs >> /tmp/rootfs-packages.specs
done