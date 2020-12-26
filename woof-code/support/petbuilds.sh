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

    if [ ! -d "../../local-repositories/petbuilds/${NAME}" ]; then
        echo "Building ${NAME}"

        mkdir -p ../../local-repositories/petbuilds/${NAME} petbuild-root
        mount -t aufs -o br=../../local-repositories/petbuilds/${NAME}:devx:rootfs-complete petbuild petbuild-root

        mkdir -p petbuild-root/proc petbuild-root/sys petbuild-root/dev petbuild-root/tmp
        mount --bind /proc petbuild-root/proc
        mount --bind /sys petbuild-root/sys
        mount --bind /dev petbuild-root/dev
        mount --bind /tmp petbuild-root/tmp

        install -D -m 755 ../packages-${DISTRO_FILE_PREFIX}/busybox/bin/busybox petbuild-root/bin/
        ../support/busybox_symlinks.sh petbuild-root > /dev/null

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

        rm -rf ../../local-repositories/petbuilds/${NAME}/tmp ../../local-repositories/petbuilds/${NAME}/etc/ssl ../../local-repositories/petbuilds/${NAME}/etc/resolv.conf ../../local-repositories/petbuilds/${NAME}/usr/share/man ../../local-repositories/petbuilds/${NAME}/usr/share/info ../../local-repositories/petbuilds/${NAME}/root/.wget-hsts ../../local-repositories/petbuilds/${NAME}/usr/share/icons/hicolor/icon-theme.cache
        rmdir ../../local-repositories/petbuilds/${NAME}/* 2>/dev/null
        find ../../local-repositories/petbuilds/${NAME} -name '.wh*' -delete
        find ../../local-repositories/petbuilds/${NAME} -name '.git*' -delete

        find ../../local-repositories/petbuilds/${NAME} -type f | while read ELF; do
            strip --strip-all -R .note -R .comment ${ELF} 2>/dev/null
        done

        for EXTRAFILE in ../rootfs-petbuilds/${NAME}/*; do
            case "${EXTRAFILE##*/}" in
            petbuild|*.patch) ;;
            *) cp -a $EXTRAFILE ../../local-repositories/petbuilds/${NAME}/
            esac
        done
    fi

    echo "Copying ${NAME}"

    rm -f rootfs-complete/pinstall.sh
    cp -a ../../local-repositories/petbuilds/${NAME}/* rootfs-complete/

    if [ -f rootfs-complete/pinstall.sh ]; then
        cat rootfs-complete/pinstall.sh >> /tmp/rootfs_pkgs_pinstall.sh
        rm -f rootfs-complete/pinstall.sh
    fi

    cat ../rootfs-petbuilds/${NAME}/pet.specs >> /tmp/rootfs-packages.specs
done