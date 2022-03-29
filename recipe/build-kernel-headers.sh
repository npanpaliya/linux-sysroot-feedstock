#!/bin/bash

# extract tarballs from rpm
mkdir -p "${SRC_DIR}/binary-kernel-headers_x"
tar -xvf "${SRC_DIR}/binary-kernel-headers" -C "${SRC_DIR}/binary-kernel-headers_x"

# add kernel headers ...
mkdir -p ${PREFIX}/${target_machine}-${ctng_vendor}-linux-gnu/sysroot
pushd ${PREFIX}/${target_machine}-${ctng_vendor}-linux-gnu/sysroot > /dev/null 2>&1
mkdir -p usr/include
cp -Rf "${SRC_DIR}"/binary-kernel-headers_x/usr/include/* usr/include/
popd
