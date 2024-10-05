#!/usr/bin/bash

set -eux

GCC_VERSION=10.5.0
MINGW_VERSION=6.0.1
WXMSW_VERSION=3.2.6
BUILD_NO=23-stl-shared-cb-winlibs1420
HOME=$(cygpath -m /home)
NAME=wxWidgets-${WXMSW_VERSION}

cp -r * /home/
cd /home

# wget -q https://github.com/zxunge/build-FreshGCC-OldMinGW-w64/releases/download/gcc-v${GCC_VERSION}-mingw-w64-v${MINGW_VERSION}/gcc-v${GCC_VERSION}-mingw-w64-v${MINGW_VERSION}-i686.7z
#wget -q https://github.com/brechtsanders/winlibs_mingw/releases/download/14.1.0posix-18.1.7-12.0.0-ucrt-r2/winlibs-i686-posix-dwarf-gcc-14.1.0-mingw-w64ucrt-12.0.0-r2.7z
# 7z x gcc-v${GCC_VERSION}-mingw-w64-v${MINGW_VERSION}-i686.7z -r -o/home
#7z x winlibs-i686-posix-dwarf-gcc-14.1.0-mingw-w64ucrt-12.0.0-r2.7z -r -o/home
wget -q https://github.com/brechtsanders/winlibs_mingw/releases/download/14.2.0posix-18.1.8-12.0.0-ucrt-r1/winlibs-i686-posix-dwarf-gcc-14.2.0-mingw-w64ucrt-12.0.0-r1.7z
7z x winlibs-i686-posix-dwarf-gcc-14.2.0-mingw-w64ucrt-12.0.0-r1.7z -o/home

export PATH=/home/mingw32/bin/:$PATH

wget -q https://github.com/wxWidgets/wxWidgets/releases/download/v${WXMSW_VERSION}/wxWidgets-${WXMSW_VERSION}.tar.bz2
tar -jxf ./wxWidgets-${WXMSW_VERSION}.tar.bz2
7z x webview2.nupkg -o./wxWidgets-${WXMSW_VERSION}/3rdparty/webview2

#wget -q https://cef-builds.spotifycdn.com/cef_binary_100.0.24%2Bg0783cf8%2Bchromium-100.0.4896.127_windows32_minimal.tar.bz2
#tar -jxf ./cef_binary_100.0.24+g0783cf8+chromium-100.0.4896.127_windows32_minimal.tar.bz2
#cd cef_binary_100.0.24+g0783cf8+chromium-100.0.4896.127_windows32_minimal/
#mkdir build && cd $_
#cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DUSE_SANDBOX=OFF ..
#make -j$(nproc) cefclient cefsimple
#ls

# Build wxWidgets
cp -f ./include/wx/msw/setup.h ./wxWidgets-${WXMSW_VERSION}/include/wx/msw/
cp -f ./build/msw/config.gcc ./wxWidgets-${WXMSW_VERSION}/build/msw/
cd wxWidgets-${WXMSW_VERSION}/build/msw
mingw32-make -f makefile.gcc setup_h
mingw32-make -f makefile.gcc -j$(nproc)

# Remove junk files in lib directory.
rm -f /home/wxWidgets-${WXMSW_VERSION}/lib/*.opt /home/wxWidgets-${WXMSW_VERSION}/lib/*.sh

7zr a -mx9 -mqs=on -mmt=on /home/${NAME}-${BUILD_NO}.7z /home/wxWidgets-${WXMSW_VERSION}/lib

if [[ -v GITHUB_WORKFLOW ]]; then
  echo "OUTPUT_BINARY=${HOME}/${NAME}-${BUILD_NO}.7z" >> $GITHUB_OUTPUT
  echo "RELEASE_NAME=wxWidgets-${WXMSW_VERSION}-${BUILD_NO}" >> $GITHUB_OUTPUT
  echo "WXMSW_VERSION=${WXMSW_VERSION}" >> $GITHUB_OUTPUT
  echo "OUTPUT_NAME=${NAME}-${BUILD_NO}.7z" >> $GITHUB_OUTPUT
fi
