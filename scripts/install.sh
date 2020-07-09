#!/usr/bin/env bash

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "No installation script for ${OSTYPE}"
  exit 1
fi

version="v1.6.0"
lib_path="/usr/local/lib/td"
inc_path="/usr/local/include/td"
ssl_path="/usr/local/opt/openssl@1.1/lib"

echo checking tdlib build $version...
if [[ -d "${lib_path}" ]] && [[ -d "${inc_path}" ]]; then
  if grep -Fxq "${version}" "${lib_path}/.version" && grep -Fxq "${version}" "${inc_path}/.version" ; then
    echo tdlib up to date!
    exit 0
  fi
fi


echo getting tdlib $version source code...
if [[ ! -d "$PWD/td" ]]
then
  git clone https://github.com/tdlib/td.git --depth 1
fi

cd td
git stash
git fetch --all --tags
git checkout tags/v1.6.0

rm -rf build
mkdir build
cd build

echo building tdlib $version...
cmake -DCMAKE_BUILD_TYPE=Release -DOPENSSL_ROOT_DIR=/usr/local/opt/openssl/ -DCMAKE_INSTALL_PREFIX:PATH=../tdlib ..
cmake --build . --target install
cd ../tdlib
echo "${version}" > ./lib/.version
echo "${version}" > ./include/td/.version


echo copying library to $lib_path...
rm -rf $lib_path
mkdir -p $lib_path
cp -r ./lib/ $lib_path
cp "${ssl_path}/libcrypto.a" $lib_path
cp "${ssl_path}/libcrypto.1.1.dylib" $lib_path
cp "${ssl_path}/libcrypto.dylib" $lib_path
cp "${ssl_path}/libssl.a" $lib_path
cp "${ssl_path}/libssl.1.1.dylib" $lib_path

echo copying headers to $inc_path...
rm -rf $inc_path
mkdir -p $inc_path
cp -r ./include/td/ $inc_path

echo tdlib $version ready!
