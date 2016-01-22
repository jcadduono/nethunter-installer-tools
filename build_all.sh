#!/bin/bash

RDIR=$(pwd)

build_hid_keyboard() {
	echo "Building hid-keyboard..."
	cd $RDIR/hid-keyboard
	make clean all
}

copy_hid_keyboard() {
	cd $RDIR/hid-keyboard
	mv hid-keyboard $OUT/
	make clean
}

build_lz4() {
	echo "Building lz4..."
	cd $RDIR/lz4
	make clean all
}

copy_lz4() {
	cd $RDIR/lz4
	mv lz4 $OUT/
	make clean
}

build_mkbootimg() {
	echo "Building mkbootimg and unpackbootimg..."
	cd $RDIR/mkbootimg
	make clean all
}

copy_mkbootimg() {
	cd $RDIR/mkbootimg
	mv mkbootimg unpackbootimg $OUT/
	make clean
}

build_libreadline() {
	echo "Building libreadline.so..."
	cd $RDIR/libreadline
	make clean all
}

copy_libreadline() {
	cd $RDIR/libreadline
	mv libreadline.so $OUT/
	make clean
}

build_libtermcap() {
	echo "Building libtermcap.so..."
	cd $RDIR/libtermcap
	make clean all
}

copy_libtermcap() {
	cd $RDIR/libtermcap
	mv libtermcap.so $OUT/
	make clean
}

build_libusb() {
	echo "Building libusb.so..."
	cd $RDIR/libusb
	make clean all
}

copy_libusb() {
	cd $RDIR/libusb
	mv libusb.so $OUT/
	make clean
}

build_proxmark3() {
	echo "Building proxmark3..."
	cd $RDIR/proxmark3
	make clean all
}

copy_proxmark3() {
	cd $RDIR/proxmark3
	mv proxmark3 $OUT/
	make clean
}

build_screenres() {
	echo "Building screenres..."
	cd $RDIR/screenres
	make clean all
}

copy_screenres() {
	cd $RDIR/screenres
	mv screenres $OUT/
	make clean
}

rm -rf $RDIR/out
mkdir $RDIR/out

for arch in arm arm64 amd64; do
	OUT=$RDIR/out/$arch
	mkdir $OUT
	ARCH=$arch . $RDIR/android

	build_hid_keyboard
	build_lz4
	build_mkbootimg
	build_libreadline
	build_libtermcap
	build_libusb
	build_proxmark3
	build_screenres

	copy_hid_keyboard
	copy_lz4
	copy_mkbootimg
	copy_libreadline
	copy_libtermcap
	copy_libusb
	copy_proxmark3
	copy_screenres
done

echo "Done."
