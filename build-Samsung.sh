echo -e "\nStarting compilation...\n"

# ENV
CONFIG=vendor/a52q_eur_open_defconfig
KERNEL_DIR=$(pwd)
PARENT_DIR="$(dirname "$KERNEL_DIR")"
export KBUILD_BUILD_USER="atlas"
export KBUILD_BUILD_HOST="c0"
export PATH="/home/atlas/toolchain/Snapdragon/prebuilt/linux-x86_64/bin:$PATH"
export LD_LIBRARY_PATH="/home/atlas/toolchain/Snapdragon/prebuilt/linux-x86_64/lib:/home/atlas/toolchain/Snapdragon/prebuilt/gcc/linux-x86/arm/arm-linux-android-4.9/lib/:/home/atlas/toolchain/Snapdragon/prebuilt/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/lib/:$LD_LIBRARY_PATH"
export KBUILD_COMPILER_STRING="$(/home/atlas/toolchain/Snapdragon/prebuilt/linux-x86_64/bin/clang --version | head -n 1 | perl -pe 's/\((?:http|git).*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//' -e 's/^.*clang/clang/')"
export out=$HOME/out-Samsung

# Functions
clang_build () {
    make -j$(nproc --all) O=$out ARCH=arm64 CC="clang" AR="llvm-ar" NM="llvm-nm" LD="ld.lld" AS="llvm-as" STRIP="llvm-strip" OBJCOPY="llvm-objcopy" OBJDUMP="llvm-objdump" CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=/home/atlas/toolchain/Snapdragon/prebuilt/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android- CROSS_COMPILE_ARM32=/home/atlas/toolchain/Snapdragon/prebuilt/gcc/linux-x86/arm/arm-linux-android-4.9/bin/arm-linux-android- DTC_EXT=/home/atlas/sources/dtc-aosp
}

# Build kernel
make O=$out ARCH=arm64 $CONFIG
echo -e "${bold}Compiling with CLANG${normal}\n$KBUILD_COMPILER_STRING"
clang_build
#if [ -f "$out/arch/arm64/boot/Image.gz-dtb" ] && [ -f "$out/arch/arm64/boot/dtbo.img" ]; then
# echo -e "\nKernel compiled succesfully! Zipping up...\n"
# ZIPNAME="StockSamsung-$(date '+%Y%m%d-%H%M').zip"
# if [ ! -d AnyKernel3 ]; then
#  git clone -q https://github.com/AzeAstro/AnyKernel3.git -b samsung
# fi;
# cp -f $out/arch/arm64/boot/Image.gz-dtb AnyKernel3
# cp -f $out/arch/arm64/boot/dtbo.img AnyKernel3
# cd AnyKernel3
# zip -r9 "$HOME/$ZIPNAME" *
# cd ..
# rm -rf AnyKernel3
# echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
# echo -e "Zip: $ZIPNAME\n"
#else
# echo -e "\nCompilation failed!\n"
#fi;
