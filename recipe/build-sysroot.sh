#!/bin/bash

set -x

mkdir -p ${PREFIX}/${target_machine}-${ctng_vendor}-linux-gnu/sysroot
pushd ${PREFIX}/${target_machine}-${ctng_vendor}-linux-gnu/sysroot > /dev/null 2>&1
cp -Rf "${SRC_DIR}"/binary/* .
mkdir -p usr/include
cp -Rf "${SRC_DIR}"/binary-tzdata/* .
cp -Rf "${SRC_DIR}"/binary-glibc-headers/usr .
cp -Rf "${SRC_DIR}"/binary-glibc-devel/* .
cp -Rf "${SRC_DIR}"/binary-glibc-common/* .

mkdir -p usr/lib
mkdir -p usr/lib64
mv usr/lib/* usr/lib64/
rm -rf usr/lib
ln -s $PWD/usr/lib64 $PWD/usr/lib

if [ -d "lib" ]; then
  pushd lib
    declare -a FILES=($(ls -1))
  popd
  # Takes care of the case when lib/ld-linux-aarch64.so.1 is a symlink to ../lib64/ld-2.17.so:
  # mv: lib/ld-linux-aarch64.so.1 and lib64/ld-linux-aarch64.so.1 are identical
  for FILE in "${FILES[@]}"; do
    if [[ ! -f lib64/${FILE} ]] && [[ ! -L lib64/${FILE} ]]; then
      mv lib/${FILE} lib64
    else
      echo "INFO :: Skipped moving lib/${FILE} to lib64/${FILE} as it exists already"
    fi
  done
  rm -rf lib
fi

if [[ "$target_machine" == "s390x" ]]; then
   rm -rf $PWD/lib64/ld64.so.*
   ln -s $PWD/lib64/ld-* $PWD/lib64/ld64.so*
fi

ln -s $PWD/lib64 $PWD/lib

cp "${SRC_DIR}"/binary-freebl/usr/lib64/libfreebl3.so ${PWD}/usr/lib64/.

popd
