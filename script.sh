#!/bin/bash

# 
# FOR LAPTOPS-NOTEBOOKS TABLETS etc... not for PC
# Anagnostakis Ioannis Greece 2023 rizitis@gmail.com

#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
#  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
#  EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Just in case...
if [ "$EUID" -ne 0 ];then
    echo "Please run this script as root"
    exit 1
fi

KERNEL_VERSION="6.5.3"
echo "$KERNEL_VERSION"

KERNEL_URL=https://cdn.kernel.org/pub/linux/kernel/v6.x  # dont change if we are still in 6.x.x kernel (NAME = Hurr 
PRGNAM=linux
GPG=gpg2
WGET=wget
JOBS=-j$(nproc)


cd /usr/src/ || exit 1
# Check if BOTH kernel version AND signature file exist
$WGET -c --spider $KERNEL_URL/linux-"$KERNEL_VERSION".tar.{sign,xz}
if [ $? ]
then
($WGET -c $KERNEL_URL/linux-"$KERNEL_VERSION".tar.{xz,sign})| sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' 
fi


# Using GnuPG to verify kernel signatures
# Not working with all kernels every time,sorry , thats why set -e starting after this step.
unxz linux-"$KERNEL_VERSION".tar.xz
$GPG --verify linux-"$KERNEL_VERSION".tar.sign
xz -cd "$KERNEL_VERSION".tar.xz | gpg2 --verify linux-"$KERNEL_VERSION".tar.sign -

while true; do
    read -p "Do you wish to proceed? " yn
    case $yn in
        [Yy]* ) echo "Proceed"; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done



mkdir -p kernel-"$KERNEL_VERSION"
cp $PRGNAM-"$KERNEL_VERSION".tar kernel-"$KERNEL_VERSION"/
cd kernel-"$KERNEL_VERSION"/ || exit 1
echo "untar Linux-kernel "
sleep 2
tar -xf $PRGNAM-"$KERNEL_VERSION".tar
echo "cd to Linux-kernel package"

cd $PRGNAM-"$KERNEL_VERSION"/ || exit 1
make LSMOD="$HOME"/.config/modprobed.db localmodconfig
#make localconfig
make CC="ccache gcc" "$JOBS"
make modules_install
wait
/usr/share/mkinitrd/mkinitrd_command_generator.sh -k "$KERNEL_VERSION" > /boot/mymkinitrd.sh
sleep 2
filename="mymkinitrd.sh"
Clear="mkinitrd -c"
NOClear="mkinitrd"
sed -i "s/$Clear/$NOClear/" /boot/"$filename"
wait
cp arch/x86_64/boot/bzImage /boot/vmlinuz-"$KERNEL_VERSION"

sh /boot/"$filename"
wait
grub-mkconfig -o /boot/grub/grub.cfg 
echo "Done...:)"

