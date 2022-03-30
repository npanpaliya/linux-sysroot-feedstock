#!/bin/bash

set -x

# extract standard compements ...
STDCOMPONENTS="binary binary-freebl binary-tzdata binary-glibc-headers binary-glibc-common binary-glibc-devel"
AWSCOMPONENTS="glibc-locale-source glibc-nss-devel libcrypt nss_db nss_hesiod nss_nis"

for std_component in $STDCOMPONENTS
  do
    mkdir -p "${SRC_DIR}/${std_component}_x"
    if [[ $(uname) == "Linux" ]]; then
      pushd "${SRC_DIR}/${std_component}_x"
      cpio -idmv <"${SRC_DIR}/${std_component}"
      popd
    else
      tar -xvf "${SRC_DIR}/${std_component}" -C "${SRC_DIR}/${std_component}_x"
    fi
  done

# for amazone some additional packages are required for a working glibc ...
if [[ "$target_machine" == "aarch64" ]]; then
  for glib_component in $AWSCOMPONENTS
    do
      mkdir -p "${SRC_DIR}/binary-${glib_component}_x"
      if [[ $(uname) == "Linux" ]]; then
        pushd "${SRC_DIR}/binary-${glib_component}_x"
        cpio -idmv <"${SRC_DIR}/binary-${glib_component}"
        popd
      else
        tar -xvf "${SRC_DIR}/binary-${glib_component}" -C "${SRC_DIR}/binary-${glib_component}_x"
      fi
    done
fi

mkdir -p ${PREFIX}/${target_machine}-${ctng_vendor}-linux-gnu/sysroot
pushd ${PREFIX}/${target_machine}-${ctng_vendor}-linux-gnu/sysroot > /dev/null 2>&1

if [[ "$target_machine" == "aarch64" ]]; then
  # Amazon Linux (at least for glibc v2.26) split out glibc components into separate RPMs.
  # Need to individually copy their contents.
  for glib_component in $AWSCOMPONENTS
    do
    cp -Rf "${SRC_DIR}"/binary-"${glib_component}_x"/* .
    done
fi

mkdir -p usr/include

for std_component in $STDCOMPONENTS
  do
    cp -Rf "${SRC_DIR}/${std_component}_x"/* .
  done

# make sure paths are exising
mkdir -p usr/lib
mkdir -p usr/lib64

mv usr/lib/* usr/lib64/
rm -rf usr/lib
ln -s $PWD/usr/lib64 $PWD/usr/lib

if [ -d "lib" ]; then
  if [[ "$target_machine" == "aarch64" ]]; then
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
  else
    mv lib/* lib64/
    rm -rf lib
  fi
fi

if [[ "$target_machine" == "s390x" ]]; then
   rm -rf $PWD/lib64/ld64.so.*
   ln -s $PWD/lib64/ld-* $PWD/lib64/ld64.so*
fi

ln -s $PWD/lib64 $PWD/lib

cp "${SRC_DIR}"/binary-freebl_x/usr/lib64/libfreebl3.so ${PWD}/usr/lib64/.

if [[ "$target_machine" == "aarch64" ]]; then
  ln -s $PWD/lib64/libcrypt-2.26.so $PWD/lib64/libcrypt.so.1
fi

popd
