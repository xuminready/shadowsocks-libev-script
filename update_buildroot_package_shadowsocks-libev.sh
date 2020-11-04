#!/bin/bash

#sudo apt-get install git-email

if [ ! -d buildroot ]; then
  echo "cloning buildroot"
  git clone git://git.buildroot.net/buildroot --depth=1
fi

cd buildroot/
git pull

git checkout -b shadowsocks-libev

pushd package/shadowsocks-libev/

curl -s https://api.github.com/repos/shadowsocks/shadowsocks-libev/releases/latest |
  grep browser_download_url |
  grep tar.gz |
  cut -d '"' -f 4 |
  wget -qi -

fileName=$(echo shadowsocks-libev*tar.gz)

version=$(echo ${fileName#'shadowsocks-libev-'})
version=${version%'.tar.gz'}

mkdir tmp_ss
tar -xf "$fileName" -C tmp_ss
shadowsocks_libev_folder_name=$(echo tmp_ss/shadowsocks-libev*)

sha256sum_shadowsocks_libev=$(sha256sum $fileName)

pushd $shadowsocks_libev_folder_name

sha256sum_copying=$(sha256sum COPYING)
sha256sum_libbloom_license=$(sha256sum libbloom/LICENSE)
sha256sum_libcork_copying=$(sha256sum libcork/COPYING)

popd
rm -rf tmp_ss
rm "$fileName"

echo "$version"

echo "# Locally computed" >shadowsocks-libev.hash
echo "sha256  $sha256sum_shadowsocks_libev" >> shadowsocks-libev.hash
echo '' >>shadowsocks-libev.hash
echo "# License files, locally calculated" >>shadowsocks-libev.hash
echo "sha256  $sha256sum_copying" >>shadowsocks-libev.hash
echo "sha256  $sha256sum_libbloom_license" >>shadowsocks-libev.hash
echo "sha256  $sha256sum_libcork_copying" >>shadowsocks-libev.hash

sed -i "s/SHADOWSOCKS_LIBEV_VERSION = .*/SHADOWSOCKS_LIBEV_VERSION = ${version}/g" shadowsocks-libev.mk

popd

git add package/shadowsocks-libev/shadowsocks-libev.hash
git add package/shadowsocks-libev/shadowsocks-libev.mk


git config user.name "Min Xu"
git config user.email xuminready@gmail.com

git commit -s -a -e -m "package/shadowsocks-libev: bump version to ${version}"
git log -p master..
git rebase origin/master
git format-patch -M -n -s -o outgoing origin/master
#./utils/get-developers outgoing/*
git send-email --to buildroot@buildroot.org --cc bob --cc alice outgoing/*
