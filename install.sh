#/bin/sh

set -e

BOOT_PART=
LINUX_PART=

mkfs.fat -F 32 $BOOT_PART

mkfs.btrfs $LINUX_PART

mount $LINUX_PART /mnt
btrfs subvolume create /mnt/@
umount /mnt

btrfs filesystem label $LINUX_PART arch

mount -o subvol=@ $LINUX_PART /mnt
mount --mkdir $BOOT_PART /mnt/boot

pacstrap -K /mnt base base-devel linux linux-firmware networkmanager

genfstab -U /mnt >> /mnt/etc/fstab

echo "root:root" | arch-chroot /mnt chpasswd

arch-chroot /mnt systemctl enable NetworkManager
arch-chroot /mnt systemctl enable fstrim.timer

bootctl --esp-path=/mnt/boot install
cp ./loader.conf /mnt/boot/loader/loader.conf
cp ./arch.conf /mnt/boot/loader/entries/arch.conf
