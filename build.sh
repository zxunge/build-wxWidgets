#!/usr/bin/bash

set -eux

GCC_VERSION=10.5.0
MINGW_VERSION=6.0.1
WXMSW_VERSION=3.2.5
BUILD_NO=2
HOME=$(cygpath -m /home)
NAME=wxWidgets-${WXMSW_VERSION}

# Install dependencies
pacman -Syy
pacman -S --noconfirm wget p7zip mingw-w64-i686-make

# Delete the existing mingw64 at C: to avoid conflicting
rm -rf /c/mingw64/bin

cp -r * /home/
cd /home


wget https://github.com/zxunge/build-FreshGCC-OldMinGW-w64/releases/download/gcc-v${GCC_VERSION}-mingw-w64-v${MINGW_VERSION}/gcc-v${GCC_VERSION}-mingw-w64-v${MINGW_VERSION}-i686.7z
7z x gcc-v${GCC_VERSION}-mingw-w64-v${MINGW_VERSION}-i686.7z -r -o/home
cp -rf ./gcc-v${GCC_VERSION}-mingw-w64-v${MINGW_VERSION}-i686/* /mingw32/

wget https://github.com/wxWidgets/wxWidgets/releases/download/v${WXMSW_VERSION}/wxWidgets-${WXMSW_VERSION}.tar.bz2
tar -jxf ./wxWidgets-${WXMSW_VERSION}.tar.bz2

# Build wxWidgets
cp -f ./setup.h ./wxWidgets-${WXMSW_VERSION}/include/wx/msw/
cp -f ./config.gcc ./wxWidgets-${WXMSW_VERSION}/build/msw/
cd wxWidgets-${WXMSW_VERSION}/build/msw
mingw32-make -f makefile.gcc setup_h
mingw32-make -f makefile.gcc -j$(nproc)

7zr a -mx9 -mqs=on -mmt=on /home/${NAME}.7z /home/wxWidgets-${WXMSW_VERSION}/lib

if [[ -v GITHUB_WORKFLOW ]]; then
  echo "OUTPUT_BINARY=${HOME}/${NAME}.7z" >> $GITHUB_OUTPUT
  echo "RELEASE_NAME=wxWidgets-${WXMSW_VERSION}-${BUILD_NO}" >> $GITHUB_OUTPUT
  echo "WXMSW_VERSION=${WXMSW_VERSION}" >> $GITHUB_OUTPUT
  echo "OUTPUT_NAME=${NAME}.7z" >> $GITHUB_OUTPUT
fi
