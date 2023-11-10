echo -e "\nStarting compilation...\n"

# ENV
CONFIG=vendor/a52q_nethunter_defconfig
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
if [ -f "$out/arch/arm64/boot/Image.gz-dtb" ] && [ -f "$out/drivers/net/wireless/realtek/rtl8188eus/8188eu.ko" ] && [ -f "$out/drivers/net/wireless/realtek/rtl8812au/88XXau.ko" ]; then
echo -e "\nKernel compiled succesfully! Zipping up...\n"

# Names
CURRENTTIME=$(date '+%Y%m%d-%H%M')
KERNELZIPNAME="NethutnerKernel-A525FXXS5DWD2-$CURRENTTIME.zip"
MAGISKZIPNAME="MagiskModule-A525FXXS5DWD2-$CURRENTTIME.zip"

# Kernel packing
if [ ! -d AnyKernel3 ]; then
   git clone -q https://github.com/AzeAstro/AnyKernel3.git -b samsung
fi;
cp -f $out/arch/arm64/boot/Image.gz-dtb AnyKernel3
cd AnyKernel3
zip -r9 "$HOME/$KERNELZIPNAME" *
cd ..
rm -rf AnyKernel3


# Kernel modules of RealTek devices
echo -e "Signing kernel modules..."
$out/scripts/sign-file sha512 $out/certs/signing_key.pem $out/certs/signing_key.x509 $out/drivers/net/wireless/realtek/rtl8188eus/8188eu.ko
$out/scripts/sign-file sha512 $out/certs/signing_key.pem $out/certs/signing_key.x509 $out/drivers/net/wireless/realtek/rtl8812au/88XXau.ko


# Packing kernel modules
echo -e "Packing kernel modules ..."
git clone -q https://github.com/AzeAstro/MagiskKernelModuleTemplate.git
cd MagiskKernelModuleTemplate
rm system/lib/modules/placeholder
cp $out/drivers/net/wireless/realtek/rtl8188eus/8188eu.ko system/lib/modules/
cp $out/drivers/net/wireless/realtek/rtl8812au/88XXau.ko system/lib/modules/
zip -r9 "$HOME/$MAGISKZIPNAME" *
cd ..
rm -rf MagiskKernelModuleTemplate

# Finishing up
echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
echo -e "Kernel Zip: $KERNELZIPNAME"
echo -e "Magisk module: $MAGISKZIPNAME\n"
else
 echo -e "\nCompilation failed!\n"
fi;
