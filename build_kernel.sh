#!/bin/bash

export ARCH=arm64
mkdir out
export out=out

BUILD_CROSS_COMPILE=/home/atlas_co/kernel/OneUI6Fresh/toolchain/gcc/bin/aarch64-linux-android-
KERNEL_LLVM_BIN=/home/atlas_co/kernel/OneUI6Fresh/toolchain/clang/bin/clang
CLANG_TRIPLE=aarch64-linux-gnu-
KERNEL_MAKE_ENV="DTC_EXT=/home/atlas_co/kernel/OneUI6/toolchain/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"

make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$KERNEL_LLVM_BIN CLANG_TRIPLE=$CLANG_TRIPLE a52q_nethunter_defconfig
make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$KERNEL_LLVM_BIN CLANG_TRIPLE=$CLANG_TRIPLE
 

files=$(find out -type f -name "*.ko")

# Loop through each file found
for file in $files; do
    echo "Found module: $file. Signing with key"
    $out/scripts/sign-file sha512 $out/certs/signing_key.pem $out/certs/signing_key.x509 $file
done
