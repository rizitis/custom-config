# custom-config
*Linux kernel custom config in a Slackware system*

This is how I created a custom .config for my omen 16 b1003xx (i7 12700h) laptop.
With this config 6-7 minutes needed to build kernel modules and install them.
Its an original **generic kernel**, builded the Slackware way.
But it may not work for everything you will need in the future...becuse it use loaded modules at the time of .config creation and only.
Also you must have a backup kernel in your installation in case of emergency... 

## HOWTO
Boot from a Slackware stock generic kernel and:

First you must plugin any device you use with you notebook: mouse, external ssd , headset...etc (everything)
Second open your browser to an online camera and microphone test site. We want camera and mic to be working durring config creation.

Download a kernel.tar.xz from [kernels.org ](https://kernel.org/)https://kernel.org/
Untar and cd in to linux folder.
Following commands are for 6.5.2 kernel version, change version with yours...
Note *that you must be in full root mode ```su -l``` DONT use only ```su```.*
Note2 *You dont need the old .config of current kernel just follow commands*
```
make localmodconfig
make -j$(getconf _NPROCESSORS_ONLN)
make modules_install
cp arch/x86_64/boot/bzImage /boot/vmlinuz-6.5.2
/usr/share/mkinitrd/mkinitrd_command_generator.sh -k 6.5.2
```
The output will start like this: `mkinitrd **-c** -k 6.5.2 blabla...`
Copy paste output in terminal **BUT BEFORE** hit enter  remove from command the option **-c**,

it should be like this:`mkinitrd -k 6.5.2 blabla...`

When finish you can updated boot loader, grub or elilo... 

This is for grub:
```
grub-mkconfig -o /boot/grub/grub.cfg
```
Reboot to test your kernel...


Remeber that even if your kernel working ok on first reboot, you should check it for few days or weeks to be sure that everything external gadget you need is working
else you should include it module...

LONG LIVE SLACKWARE!
