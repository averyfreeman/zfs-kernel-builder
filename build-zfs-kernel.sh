#!/usr/bin/env bash +xv
# Last updated 1-22-21
# Script requires 3 arguments:
# ZFS_VER KERNEL_VER and MAKECOMMAND
export ZFS_VER=$1
export KERNEL_VER=$2
export MAKECOMMAND=$3
LATEST_ZFS=$(curl -s https://github.com/openzfs/zfs/releases | egrep -m 1 '.tar.gz' | tr -s ' ' | cut -d ' ' -f3 | sed 's/^.*zfs/zfs/')
# example: 
# ./build_kernel.sh 2.0.3 5.8.18 modconfig
# gratuitous intro for first-timers
echo "This script builds a kernel with zfs builtin modules. It will "
echo "attempt to use clang for all processes, but depending on your"
echo "environment, it might end up using gcc for the kernel portion."
echo ""
echo "The script is mostly unattended, but it may ask you questions about"
echo "options to add to your kernel build, so be sure and check on it now and"
echo "then... It will build the kernel you specify based on your currently" 
echo "booted kernel: $(uname -r)"
echo ""
echo "Press enter to continue"
read gee
echo "If you haven't installed your kernel headers package yet, hit"
echo "CTRL-C and run the install-build-requirements.sh script first."
echo ""
echo "To use the script, at least two arguments are required:"
echo "build-zfs-kernel.sh ZFS_VERSION KERNEL_VERSION MAKECONFIG"
echo ""
echo "Example: "
echo " ./buildkernel 2.0.3 5.10.18 modconfig"
echo ""
echo "MAKECONFIG is not required, but first two are."
echo "Press enter to continue"
read yee
echo "Your current kernel version is $(uname -r)"
echo "Latest version of zfs is: $LATEST_ZFS"
echo "As of writing, latest stable kernel 5.10.16 - you can check here for updates:"
echo "https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/ "
echo ""
echo "Hit CTRL-C to abort or enter to continue"
read key

# use gcc:
#export CC=cc CXX=c++ HOSTCC=cc HOSTCXX=c++ HOSTLD=ld STRIP=strip NM=nm OBJDUMP=objdump OBJCOPY=objcopy TOOLCHAIN="gnu"
# use clang:
export CC=clang CXX=clang++ HOSTCC=clang HOSTCXX=clang++ LD=ld.lld HOSTLD=ld.lld STRIP=llvm-strip NM=llvm-nm OBJDUMP=llvm-objdump OBJCOPY=llvm-objcopy DLLTOOL=llvm-dlltool TOOLCHAIN="llvm"

export VENDOR=$(lsb_release -i -s)
export CODENAME=$(lsb_release -c -s)
export APPENDAGE=.zfs 
# note: $APPENDAGE doesn't echo variable in sed (kernel conf)
# APPENDAGE=.clang.zfs 

echo "Creating build directory and downloading source files"
ROOT_BUILD_DIR=./z$ZFS_VER-k$KERNEL_VER
if test -f "$ROOT_BUILD_DIR"; then
    echo "$ROOT_BUILD_DIR exists."
   else
    mkdir $ROOT_BUILD_DIR
fi

cd $ROOT_BUILD_DIR

KERNEL_TAR=linux-$KERNEL_VER.tar.xz
if test -f "$KERNEL_TAR"; then
    echo "$KERNEL_TAR exists."
   else
    wget https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/linux-$KERNEL_VER.tar.xz
    wget https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/linux-$KERNEL_VER.tar.sign
fi

ZFS_TAR=zfs-$ZFS_VER.tar.gz
if test -f "$ZFS_TAR"; then
    echo "$ZFS_TAR exists."
   else
    wget https://github.com/openzfs/zfs/releases/download/zfs-$ZFS_VER/zfs-$ZFS_VER.tar.gz
fi

unxz linux-$KERNEL_VER.tar.xz &> /dev/null
gpg2 --verify linux-$KERNEL_VER.tar.sign


mkdir linux-$KERNEL_VER$APPENDAGE
tar xvf linux-$KERNEL_VER.tar -C ./linux-$KERNEL_VER$APPENDAGE --strip-components=1 &> /dev/null

mkdir zfs-$ZFS_VER-k$KERNEL_VER
tar xvf zfs-$ZFS_VER.tar.gz -C ./zfs-$ZFS_VER-k$KERNEL_VER --strip-components=1 &> /dev/null

export ZFS_DIR=$(pwd)/zfs-$ZFS_VER-k$KERNEL_VER
export KERNEL_DIR=$(pwd)/linux-$KERNEL_VER$APPENDAGE

cd $KERNEL_DIR

echo "Copying last known working .config file"
cp /usr/src/linux-headers-$(uname -r)/.config ./.config
# cp ../../config-latest $KERNEL_DIR/.config

if test -f "$MAKECOMMAND"; then
    echo "make $MAKECOMMAND will be executed"
    make $MAKECOMMAND
   else
   echo "no make command specified"
fi

echo "Setting kernel build flags - IMPORTANT NOTE: "
echo "This process will likely ask you questions later, so keep an eye on it"

echo "Adding $APPENDAGE string to the end of the kernel identifier"
# append .zfs
sed -i 's/CONFIG_LOCALVERSION="*.*/CONFIG_LOCALVERSION=".zfs"/g' .config
sed -i 's/# CONFIG_LOCALVERSION_AUTO is not set/CONFIG_LOCALVERSION_AUTO=y/g' .config

echo "Enabling SMB direct and BPF LSM - bonus!"
sed -i 's/# CONFIG_CIFS_SMB_DIRECT is not set/CONFIG_CIFS_SMB_DIRECT=y/g' .config
sed -i 's/# CONFIG_BPF_LSM is not set/CONFIG_BPF_LSM=y/g' .config

echo "Saving as default .config for future reference"
make savedefconfig
echo "Preparing - Note:"
echo "if orig .config is older than $KERNEL_VER, it will ask you about new features"
echo "But you can safely hit ENTER for all of these questions"
make prepare

echo "Creating configuration for zfs build"
cd $ZFS_DIR

export CC=clang CXX=clang++ HOSTCC=clang HOSTCXX=clang++ LD=ld.lld HOSTLD=ld.lld STRIP=llvm-strip NM=llvm-nm OBJDUMP=llvm-objdump OBJCOPY=llvm-objcopy DLLTOOL=llvm-dlltool WITH_GNU_LD="--with-gnu-ld=no" TOOLCHAIN="llvm"
export WITH_BUILTIN="--enable-linux-builtin"

make clean && make distclean
sh autogen.sh

# --disable-silent-rules \

./configure \
  --prefix=/usr \
  --disable-nls \
    $WITH_BUILTIN \
  --enable-pam \
  --enable-pyzfs \
    $WITH_GNU_LD \
  --with-vendor=$VENDOR \
  --without-libintl-prefix \
  --with-linux=$KERNEL_DIR \
  --with-linux-obj=$KERNEL_DIR
  
echo "Copying built-in modules to kernel dir"
./copy-builtin $KERNEL_DIR

echo "Building zfs .deb packages"
# note: needs plain make first (?)
make -j$(nproc) && make deb-utils -j$(nproc)
# make -j$(nproc) deb-utils

# echo "Making kernel module package specific to this kernel"
# make -j$(nproc) && make deb-kmod -j$(nproc) 
mv *.deb ../

echo "Building kernel -- *** IF IT ASKS YOU ABOUT ZFS, SAY y !! ***"
cd $KERNEL_DIR
#export CC=cc CXX=c++ HOSTCC=cc HOSTCXX=c++ HOSTLD=ld STRIP=strip NM=nm OBJDUMP=objdump OBJCOPY=objcopy ZFS_FLAG="CONFIG_ZFS=y"
#if grep -q $ZFS_FLAG  .config
#then 
#   echo ".config OK";
#else
cat >>.config <<EOF
CONFIG_ZFS=y
EOF
#fi
   echo ".config appended with CONFIG_ZFS=y"

# all build procecsses not necessary
#make -j$(nproc) && make bzImage -j$(nproc) && make modules -j$(nproc) && make deb-pkg -j$(nproc)
make deb-pkg -j$(nproc)

cd .. 
mkdir unnecessary-debs
mv zfs-initramfs*.deb zfs-dracut*.deb unnecessary-debs/

echo "All done!  Your .deb files should be in new-build dir"
echo "You can install them all with sudo apt install -y ./*.deb"


