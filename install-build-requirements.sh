#!/bin/env sh -v
# uncomment deb-src for main first
echo "this script installs requirements for building kernels on a debian-based distribution"
echo "if you're not using debian, ubuntu, etc. this script is not for you"
read "press enter to continue"

sudo sed -i 's/# deb-src http/deb-src http/g' /etc/apt/sources.list
sudo apt update
sudo apt build-dep linux linux-image-$(uname -r)

sudo apt install -y build-essential autoconf automake libtool gawk alien fakeroot curl dkms libblkid-dev uuid-dev libudev-dev libssl-dev zlib1g-dev libaio-dev libattr1-dev libelf-dev linux-headers-$(uname -r) python3 python3-dev python3-setuptools python3-cffi libffi-dev dwarves llvm-11 clang-11 clang-11-doc lld-11 lldb-11 libpam0g-dev

# makes symlinks for llvm/clang related tools to normalize names
for i in clang clang++ ld.lld llvm-strip llvm-nm llvm-objdump llvm-objcopy llvm-dlltool llvm; do sudo ln -s /usr/bin/"$i"-11 /usr/bin/"$i"; done
