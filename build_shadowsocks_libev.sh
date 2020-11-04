#!/bin/bash

#sudo apt update
#sudo apt install autoconf libtool libpcre3-dev libc-ares-dev libev-dev

diagnostic() {
  echo "$@" 1>&2
}

checkfail() {
  if [ ! $? -eq 0 ]; then
    diagnostic "$1"
    exit 1
  fi
}

PREFIX=$(pwd)/shadowsocks
mkdir $PREFIX

# Installation of libsodium
if [ ! -d "libsodium-stable" ]; then
  diagnostic "libsodium source not found, cloning"
  wget https://download.libsodium.org/libsodium/releases/LATEST.tar.gz -O libsodium.tar.gz
  tar xvf libsodium.tar.gz
  checkfail "libsodium source: git clone failed"
fi

pushd libsodium-stable
./configure --prefix=$PREFIX && make -j$(nproc)
make install
popd

# Installation of MbedTLS
if [ ! -d "mbedtls" ]; then
  diagnostic "mbedtls source not found, cloning"
  git clone --depth=1 https://github.com/ARMmbed/mbedtls.git
  checkfail "mbedtls source: git clone failed"
fi
diagnostic "shadowsocks-libev source found"
pushd mbedtls
make SHARED=1 CFLAGS=-fPIC
make DESTDIR=$PREFIX install -j$(nproc)
popd

if [ ! -d "shadowsocks-libev" ]; then
  diagnostic "shadowsocks-libev source not found, cloning"
  git clone --depth=1 https://github.com/shadowsocks/shadowsocks-libev.git
  checkfail "shadowsocks-libev source: git clone failed"
fi
diagnostic "shadowsocks-libev source found"
pushd shadowsocks-libev
git pull
git submodule update --init --recursive

# Start building
./autogen.sh && ./configure --disable-documentation --with-sodium=$PREFIX --with-mbedtls=$PREFIX --prefix=$PREFIX && make -j$(nproc)
make install
popd
