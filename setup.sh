#/bin/sh

set -e

USER_NAME=
USER_PASS=
DOTFILES_REPO=

function run_as_user() {
  sudo --user $USER_NAME $@
}

function run_as_user_chdir() {
  cd $1
  sudo --user $USER_NAME ${$@:2}
  cd -
}

pacman -Syu --noconfirm

pacman -S --noconfirm git fish sudo btrfs-progs

chmod 640 /etc/sudoers
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

useradd --shell /bin/fish --create-home --btrfs-subvolume-home $USER_NAME
usermod --append --groups wheel $USER_NAME
echo "$USER_NAME:$USER_PASS" | chpasswd

run_as_user mkdir /home/$USER_NAME/Downloads

run_as_user_chdir /home/$USER_NAME/Downloads git clone https://aur.archlinux.org/paru-bin
run_as_user_chdir /home/$USER_NAME/Downloads/paru-bin makepkg --syncdeps --install --noconfirm

pacman -S --noconfirm pipewire pipewire-audio wireplumber pipewire-alsa pipewire-pulse pipewire-jack pavucontrol

pacman -S --noconfirm bluez bluez-utils
systemctl enable bluetooth

pacman -S --noconfirm xorg-server xorg-xinit

pacman -S --noconfirm lightdm lightdm-gtk-greeter
systemctl enable lightdm

pacman -S --noconfirm i3-wm

run_as_user paru -S --noconfirm dfm
run_as_user git clone $DOTFILES_REPO /home/$USER_NAME/.df
run_as_user dfm apply --force

sudo --user $USER_NAME paru -S --noconfirm \
  pacman-contrib \
  man-db \
  firefox \
  neovim \
  visual-studio-code-bin \
  libreoffice \
  evince \
  spotify \
  slack-desktop \
  signal-desktop \
  discord \
  jdk8-openjdk \
  jdk-openjdk \
  rustup \
  alacritty \
  bat \
  bottom \
  git-delta \
  exa \
  fd \
  ripgrep \
  starship \
  tealdeer \
  tokei \
  zoxide \
  zellij \
  difftastic \
  ncdu \
  vlc \
  thunar \
  flameshot \
  sl \
  openssh \
  cowfortune \
  cowsay \
  lolcat \
  polybar \
  lsp-plugins \
  picom \
  rofi \
  zip \
  unzip
