#!/bin/bash

# Prereq
apt-get update
apt-get install -y gcc build-essential libncurses5-dev libpam0g-dev wget git \
	libsepol1-dev libselinux1-dev make pkg-config autoconf flex bison file

# Setup toolchain/NDK
DIRECTORY=~/build/ndk

if [ ! -d "$DIRECTORY" ]; then
	mkdir -p ~/build/ndk ~/build/toolchain
	cd ~/build/ndk
	wget http://dl.google.com/android/ndk/android-ndk-r10e-linux-x86_64.bin
	chmod +x android-ndk-r10e-linux-x86_64.bin
	./android-ndk-r10e-linux-x86_64.bin
	rm android-ndk-r10e-linux-x86_64.bin
fi

# Create toolchain
cd ~/build/ndk/android-ndk-r10e
./build/tools/make-standalone-toolchain.sh --platform=android-21 --toolchain=arm-linux-androideabi-4.9 --install-dir="$HOME/build/toolchain/android-armhf-4.9"
./build/tools/make-standalone-toolchain.sh --platform=android-21 --toolchain=aarch64-linux-android-4.9 --install-dir="$HOME/build/toolchain/android-arm64-4.9"
./build/tools/make-standalone-toolchain.sh --platform=android-21 --toolchain=x86_64-4.9 --install-dir="$HOME/build/toolchain/android-amd64-4.9"
./build/tools/make-standalone-toolchain.sh --platform=android-21 --toolchain=x86-4.9 --install-dir="$HOME/build/toolchain/android-i386-4.9"

# Export path
echo "export PATH=$PATH:~/build/ndk/android-ndk-r10e" >> ~/.bashrc
source ~/.bashrc
