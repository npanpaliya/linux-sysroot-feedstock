#!/bin/bash

mkdir -p ${PREFIX}/${target_machine}-${ctng_vendor}-linux-gnu/sysroot
pushd ${PREFIX}/${target_machine}-${ctng_vendor}-linux-gnu/sysroot > /dev/null 2>&1
cp -Rf "${SRC_DIR}"/binary/* .

mkdir -p usr/lib
mkdir -p usr/lib64
mkdir -p usr/include

mkdir -p usr/include
cp -Rf "${SRC_DIR}"/binary-tzdata/* usr/
cp -Rf "${SRC_DIR}"/binary-glibc-headers/include/* usr/include/
cp -Rf "${SRC_DIR}"/binary-glibc-devel/* usr/
cp -Rf "${SRC_DIR}"/binary-glibc-common/* .

echo "Error: "
ls usr/lib/
#mv usr/lib/* usr/lib64/
rm -rf usr/lib
ln -s $PWD/usr/lib64 $PWD/usr/lib

if [ -d "lib" ]; then
    mv lib/* lib64/
    rm -rf lib
fi

if [[ "$target_machine" == "s390x" ]]; then
   rm -rf $PWD/lib64/ld64.so.*
   ln -s $PWD/lib64/ld-* $PWD/lib64/ld64.so*
fi

ln -s $PWD/lib64 $PWD/lib

cp "${SRC_DIR}"/binary-freebl/lib64/libfreebl3.so ${PWD}/usr/lib64/.

popd
