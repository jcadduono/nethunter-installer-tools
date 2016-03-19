#!/bin/bash

RDIR=$(pwd)

[ -d "$RDIR/out" ] || {
	echo "You need to ./build_all.sh first!"
	exit -1
}

cd $RDIR/out
rm -rf nethunter-installer

ARCH_COMMON=nethunter-installer/common/arch
ARCH_UPDATE=nethunter-installer/update/arch
ARCH_BOOT=nethunter-installer/boot-patcher/arch

for arch in armhf arm64 amd64 i386; do
	echo "Setting up $arch..."
	# set vars
	case $arch in
		*64)	lib=lib64;;	
		*) lib=lib;;
	esac

	# update tools
	to=$ARCH_UPDATE/$arch/tools
	mkdir -p $to
	cp $arch/busybox $arch/screenres $to/

	# update system/bin
	to=$ARCH_UPDATE/$arch/system/bin
	mkdir -p $to
	cp $arch/proxmark3 $arch/mkfs.fat $to/

	# update system/lib or /system/lib64
	to=$ARCH_UPDATE/$arch/system/$lib
	mkdir -p $to
	cp $arch/libncurses.so $arch/libreadline.so $arch/libtermcap.so $arch/libusb.so $to/

	# boot-patcher /sbin
	to=$ARCH_BOOT/$arch/ramdisk-patch/sbin
	mkdir -p $to
	cp $arch/busybox $to/busybox_nh

	# boot-patcher /system/xbin
	to=$ARCH_BOOT/$arch/system/xbin
	mkdir -p $to
	cp $arch/hid-keyboard $to/

	# boot-patcher tools
	to=$ARCH_BOOT/$arch/tools
	mkdir -p $to
	cp $arch/lz4 $arch/mkbootimg $arch/unpackbootimg $to/
done

echo "Done."
