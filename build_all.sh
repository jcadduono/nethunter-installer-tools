#!/bin/bash

RDIR=$(pwd)
git submodule init
git submodule update

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
	
	./configure --host=$HOST --disable-utmp --disable-wtmp --disable-utmpx --disable-utmpx --disable-zlib --disable-syslog --prefix=/data/local/nhsystem
    make clean all
}

copy_dropbear() {
	cd $RDIR/dropbear
	mv dropbear $OUT/
	mv dropbearconvert $OUT/
	mv dropbearkey $OUT/
	mv dbclient $OUT/
	make clean
}

build_busybox() {
	cd $RDIR/busybox
	# Check if patch already applied
	patch -p1 -N --dry-run --silent < ../patches/busybox.patch 2>/dev/null
	if [ $? -eq 1 ]; then
		#apply the patch
		patch -p1 -N < ../patches/busybox.patch
	fi
	cp ../patches/busybox_config .config
	make CROSS_COMPILE=$CROSS_COMPILE "LDFLAGS=-static -fuse-ld=bfd"
}

copy_busybox(){
	cd $RDIR/busybox
	mv busybox $OUT/
	mv busybox_unstripped $OUT/
	make clean
}

build_nmap(){
	# Build OPNESSL
	cd $RDIR/openssl-1.0.2e
	echo "Building openssl"
	CC=$CC AR="$AR r" RANLIB=$RANLIB LDFLAGS="-static" ./Configure dist --prefix=/data/local/nhsystem/openssl
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
	--with-liblua=included --with-libpcap=internal --with-pcap=linux --enable-static --prefix=/data/local/nhsystem/nmap7 \
	--with-openssl=/data/local/nhsystem/openssl

	make
	make install
}

copy_nmap(){
	cd $RDIR/openssl-1.0.2e
	make clean
    cd $RDIR/nmap
	make clean
	$STRIP /data/local/nhsystem/nmap7/bin/nmap
	$STRIP /data/local/nhsystem/nmap7/bin/ncat
	$STRIP /data/local/nhsystem/nmap7/bin/nping
	cp -rf /data/local/nhsystem/nmap7/bin/* $OUT/

	# Remove nmap/openssl (binaries are copied)
	rm -rf /data/local/nhsystem/nmap7
	rm -rf /data/local/nhsystem/openssl
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
}

copy_tcpdump(){
	cd $RDIR/tcpdump
	$STRIP $SYSROOT/usr/local/sbin/tcpdump
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
    mv $SYSROOT/usr/bin/socat $OUT
    rm -f $SYSROOT/usr/bin/socat
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
	make clean static
}

copy_mkbootimg() {
	cd $RDIR/mkbootimg
	mv mkbootimg-static unpackbootimg-static $OUT/
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

for arch in armhf arm64 amd64 i386; do
	OUT=$RDIR/out/$arch
	mkdir -p $OUT
	ARCH=$arch . $RDIR/android

	build_dropbear
	build_busybox
    build_socat
	build_nmap
	build_tcpdump
	build_hid_keyboard
	build_lz4
	build_mkbootimg
	build_libreadline
	build_libtermcap
	build_libusb
	build_proxmark3
	build_screenres

	copy_dropbear
	copy_busybox
    copy_socat
	copy_nmap
	copy_tcpdump
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
