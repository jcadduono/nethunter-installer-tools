#!/bin/bash

RDIR=$(pwd)

# if $@, build and copy only that project
if [ "$@" ]; then
	PROJECTS=$@
else
	PROJECTS="busybox hid_keyboard lz4 mkbootimg libreadline libtermcap libusb proxmark3 screenres"
fi

f_exists() {
	type $1 > /dev/null 2>&1 || return 1
}

#unset static
export STATIC=

setup_busybox() {
	cd $RDIR/busybox
	git reset --hard HEAD
	git clean -xdf
	# check if patch is applicable
	patch -p1 -N --dry-run --silent < $RDIR/patches/busybox.patch 2>/dev/null
	if [ $? -eq 1 ]; then
		# apply the patch
		patch -p1 -N < $RDIR/patches/busybox.patch
	else
		echo "Can't patch busybox!"
		exit 1
	fi
	cp $RDIR/patches/busybox_config .config
}

build_busybox() {
	cd $RDIR/busybox
	make clean all
	$STRIP --strip-all busybox
}

copy_busybox() {
	cd $RDIR/busybox
	mv busybox $OUT/
	make clean
}

build_hid_keyboard() {
	echo "Building hid-keyboard..."
	cd $RDIR/hid-keyboard
	make clean all
	$STRIP --strip-all hid-keyboard
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
	$STRIP --strip-all lz4
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
	$STRIP --strip-all mkbootimg
	$STRIP --strip-all unpackbootimg
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
	$STRIP libreadline.so
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
	$STRIP libtermcap.so
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
	$STRIP libusb.so
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
	$STRIP --strip-all proxmark3
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
	$STRIP --strip-all screenres
}

copy_screenres() {
	cd $RDIR/screenres
	mv screenres $OUT/
	make clean
}

rm -rf $RDIR/out
mkdir $RDIR/out

for arch in armhf arm64 amd64 i386; do
	OUT=$RDIR/out/$arch
	mkdir $OUT

	# set up projects that need it
	for project in $PROJECTS; do
		f_exists setup_$project && setup_$project
	done

	# these should be compiled static (dynamic is not safe in recovery environment)
	STATIC=1 ARCH=$arch . $RDIR/android

	for project in $PROJECTS; do
		case $project in
			busybox|lz4|mkbootimg|screenres) build_$project;;
		esac
	done

	# these should be compiled dynamic
	ARCH=$arch . $RDIR/android

	for project in $PROJECTS; do
		case $project in
			libreadline|libtermcap|libusb|proxmark3|hid_keyboard) build_$project;;
		esac
	done

	# copy all projects to out folder
	for project in $PROJECTS; do
		f_exists copy_$project && copy_$project
	done
done

echo "Done."
