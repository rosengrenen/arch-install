#/bin/sh

set -e

BOOT_PART=
LINUX_PART=
ROOT_PASS=

mkfs.fat -F 32 $BOOT_PART

mkfs.btrfs $LINUX_PART

mount $LINUX_PART /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
umount /mnt

btrfs filesystem label $LINUX_PART arch

mount -o subvol=@ $LINUX_PART /mnt
mount -o subvol=@home $LINUX_PART /mnt/home
mount --mkdir $BOOT_PART /mnt/boot

pacstrap -K /mnt base base-devel linux linux-firmware networkmanager

genfstab -U /mnt >> /mnt/etc/fstab

echo "root:$ROOT_PASS" | arch-chroot /mnt chpasswd

arch-chroot /mnt systemctl enable NetworkManager
arch-chroot /mnt systemctl enable fstrim.timer

bootctl --esp-path=/mnt/boot install
cp ./loader.conf /mnt/boot/loader/loader.conf
cp ./arch.conf /mnt/boot/loader/entries/arch.conf
