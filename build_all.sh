#!/bin/bash

RDIR=$(pwd)

# Get all submodules
git submodule init
git submodule update

# if $@, build and copy only that project
if [ "$1" ]; then
	PROJECTS="$*"
else
	PROJECTS="busybox hid_keyboard lz4 mkbootimg libncurses libreadline libtermcap \
			  dropbear socat nmap tcpdump libusb proxmark3 screenres flash_image xz"
fi

f_exists() {
	type $1 > /dev/null 2>&1 || return 1
}

#unset static
export STATIC=

build_dropbear() {
    echo "Building dropbear..."
    cd $RDIR/dropbear
	autoconf && autoheader

	# Check if patch already applied
	patch -p1 -N --dry-run --silent < ../patches/dropbear.patch 2>/dev/null
	if [ $? -eq 1 ]; then
		#apply the patch
		patch -p1 -N < ../patches/dropbear.patch
	fi
	./configure --host=$HOST --disable-utmp --disable-wtmp --disable-utmpx --disable-utmpx --disable-zlib --disable-syslog --prefix=$PREFIXDIR
    make clean all
    $STRIP --strip-all dropbear dropbearconvert dropbearkey dbclient
}

copy_dropbear() {
	cd $RDIR/dropbear
	mv dropbear $OUT/
	mv dropbearconvert $OUT/
	mv dropbearkey $OUT/
	mv dbclient $OUT/
	make clean
}

setup_busybox() {
	cd $RDIR/busybox
	git clean -xdf
	git reset --hard b9b7aa1
	# check if patch is applicable
	patch -p1 -N --dry-run --silent < $RDIR/patches/busybox.diff 2>/dev/null
	if [ $? -eq 0 ]; then
		# apply the patch
		patch -p1 -N < $RDIR/patches/busybox.diff
	else
		echo "Can't patch busybox!"
		exit 1
	fi
	cp $RDIR/patches/busybox_config .config
}

build_busybox() {
	cd $RDIR/busybox
	make clean all CROSS_COMPILE=$CROSS_COMPILE "LDFLAGS=-static -fuse-ld=bfd" $EXTRAVERSION
	$STRIP --strip-all busybox
}

build_nmap(){
	# Build OPNESSL
	cd $RDIR/openssl-1.0.2e
	echo "Building openssl"
	CC=$CC AR="$AR r" RANLIB=$RANLIB LDFLAGS="-static" ./Configure dist --prefix=$PREFIXDIR/openssl
	make clean
	make CC=$CC AR="$AR r" RANLIB=$RANLIB LDFLAGS="-static"
	make install

	# Build nmap
	echo "Building nmap"
	cd $RDIR/nmap

	# Configuration options...there's a lot...
	LUA_CFLAGS="-DLUA_USE_POSIX -fvisibility=default -fPIE" ac_cv_linux_vers=2 CC=$CC LD=$LD CXX=$CXX \
	AR=$AR RANLIB=$RANLIB STRIP=$CROSS_COMPILEstrip CFLAGS="-fvisibility=default -fPIE" CXXFLAGS="-fvisibility=default -fPIE" \
	LDFLAGS="-rdynamic -pie" ./configure --host=$HOST --without-ndiff --without-nmap-update --without-zenmap \
	--with-liblua=included --with-libpcap=internal --with-pcap=linux --enable-static --prefix=$PREFIXDIR/nmap7 \
	--with-openssl=$PREFIXDIR/openssl
	make
	make install
}

copy_nmap(){
	cd $RDIR/openssl-1.0.2e
	make clean
    cd $RDIR/nmap
	make clean
    $STRIP --strip-all nmap
    $STRIP --strip-all ncat
	cp -rf $PREFIXDIR/nmap7/bin/* $OUT/

	# Remove nmap/openssl (binaries are copied)
	rm -rf $PREFIXDIR/nmap7
	rm -rf $PREFIXDIR/openssl
}

build_tcpdump(){
	echo "Building libpcap"
	cd $RDIR/libpcap
	LDFLAGS=-static ./configure --host=$HOST --with-pcap=linux ac_cv_linux_vers=2
	make
	make install

	echo "Building TCPDUMP"
	cd $RDIR/tcpdump
	sed -i".bak" "s/setprotoent/\/\/setprotoent/g" print-isakmp.c
	sed -i".bak" "s/endprotoent/\/\/endprotoent/g" print-isakmp.c
	./configure --host=$HOST ac_cv_linux_vers=2 --with-crypto=no
	make
	make install
    $STRIP --strip-all tcpdump
}

copy_tcpdump(){
	cd $RDIR/tcpdump
	mv $SYSROOT/usr/local/sbin/tcpdump $OUT/
	make clean
}

build_socat(){
    cd $RDIR/socat-android
    autoconf
    autoheader
    mv $SYSROOT/usr/include/resolv.h $SYSROOT/usr/include/resolv.h.bak
    ./configure --host=$HOST --disable-openssl --disable-unix ac_header_resolv_h=no ac_cv_c_compiler_gnu=yes ac_compiler_gnu=yes
    sed 's/-lpthread//g' -i Makefile
    make clean all
}

copy_socat(){
    mv $RDIR/socat-android/socat $OUT
    make clean
}

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

build_xz() {
	echo "Building xz..."
	cd $RDIR/xz
	./autogen.sh
	./configure --host=$HOST
	make clean all
	cd src/xz
	make clean all
	cd .libs
	$STRIP --strip-all xz
}

copy_xz() {
	cd $RDIR/xz
	mv src/xz/.libs/xz $OUT/
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
	make client
	$STRIP --strip-all client/proxmark3
}

copy_proxmark3() {
	cd $RDIR/proxmark3/client
	mv proxmark3 $OUT/
	cd $RDIR/proxmark3
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

build_flash_image() {
	echo "Building flash_image..."
	cd $RDIR/flash_image
	make clean all
	$STRIP --strip-all flash_image
}

copy_flash_image() {
	cd $RDIR/flash_image
	mv flash_image $OUT/
	make clean
}

setup_libncurses() {
	cd $RDIR/libncurses
	git reset --hard HEAD
	git clean -xdf
	cp -f $RDIR/patches/libncurses_makefile Makefile
}

build_libncurses() {
	echo "Building libncurses.so..."
	cd $RDIR/libncurses
	make clean all
	$STRIP libncurses.so
}

copy_libncurses() {
	cd $RDIR/libncurses
	mv libncurses.so $OUT/
	make clean
}

build_flash_image() {
	echo "Building flash_image..."
	cd $RDIR/flash_image
	make clean all
	$STRIP --strip-all flash_image
}

copy_flash_image() {
	cd $RDIR/flash_image
	mv flash_image $OUT/
	make clean
}

rm -rf $RDIR/out
mkdir $RDIR/out

for arch in armhf arm64 amd64 i386; do
	OUT=$RDIR/out/$arch
	mkdir -p $OUT

	# set up projects that need it
	for project in $PROJECTS; do
		f_exists setup_$project && setup_$project
	done

	# these should be compiled static (dynamic is not safe in recovery environment)
	STATIC=1 ARCH=$arch . $RDIR/android
	for project in $PROJECTS; do
		case $project in
			busybox|lz4|mkbootimg|screenres|flash_image|xz) build_$project;;
		esac
	done

	# these should be compiled dynamic
	ARCH=$arch . $RDIR/android
	for project in $PROJECTS; do
		case $project in
			libncurses|libreadline|libtermcap|libusb|proxmark3|hid_keyboard|socat|nmap|tcpdump|dropbear) build_$project;;
		esac
	done

	# copy all projects to out folder
	for project in $PROJECTS; do
		f_exists copy_$project && copy_$project
	done
done

echo "Done."
