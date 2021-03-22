#!/bin/bash
y="\e[1;33m"
w="\e[1;37m"
r="\e[0m"


echo -e "${y}      ${w}.    .                       ${r}"
echo -e "  ${w}.   .${y}:${w}...     ....              "
echo -e " ${w}.  .${y}::${w}...${y}::${w}..         ...        "
echo -e "${w}.  .${y}::${w}.${y}:::${w}.  .${y}::::---${y}::${w}. .${y}:${w}.      "
echo -e "  ${w}.${y}::::${w}-.  .${y}:${w}----${y}:${w}------....      "
echo -e "${w}.  ${y}:::${w}-. .----------${y}:::::${w}.        "
echo -e "${w}. .${y}:::${w}-. -----${y}:${w}....      ....     "
echo -e "${w}.  .-${y}:${w}-. ${y}:${w}--${y}:${w}.  .${y}::::${w}---${y}:${w}.  .${y}:${w}.   "
echo -e " ${w}..  .${y}:: ${w}.${y}:${w}. .${y}::${w}--${y}:::${w}---${y}::${w}.  .${y}:${w}.  "
echo -e "   ${w}..  ${y}:${w}.${y}:${w}. ${y}:${w}---${y}::::::::::::${w}. .${y}:${w}. "
echo -e "     ${w}...-${y}: ${w}.--${y}::::::${w}.${y}::::::::  ${w}.${y}: "
echo -e        "     ${w}....      .        .."
echo -e "${y}Citr${w}OS build script"
echo -e "                      2021 The ${y}Citr${w}OS Project${r}"

# Functions / Vars

# Yoinked from https://stackoverflow.com/questions/12498304/using-bash-to-display-a-progress-indicator/20369590#20369590
spinner()
{
    local pid=$!
    local delay=0.73
    local spinstr=':|/-\|/-\|:  '
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}
buildt=$(date +"Built on %D at %T.%3N by $(whoami)")



sleep 4
# Make build folder, get files ready and builds.

echo "Making root build dir..."
mkdir -p -v citros/live-build-buster > /dev/null
cd citros/live-build-buster/

# Config it.
# Check out "man lb config" ;)

# system: live/normal 
# bootloaders: grub-legacy|grub-pc|syslinux|grub-efi
# debian-installer: true|cdrom|netinst|netboot|businesscard|live|false 

echo "Configuring..."
sudo lb config noauto \
    -b iso-hybrid \
    --apt-options "--force-yes --yes" \
    --cache true \
    --clean \
    --system live \
    --apt-recommends true \
    --architecture amd64 \
    --mode debian \
    --debian-installer normal \
    --debian-installer-gui true \
    --security true \
    --backports true \
    --updates true \
    --image-name "CitrOS" \
    --iso-volume "CitrOS" \
    --debian-installer live -d buster \
    --debian-installer-distribution daily \
    --bootappend-live "boot=live components keyboard-layouts=fi username=edible user-fullname=CitrOS" \
    --bootappend-install "components keyboard-layouts=fi username=edible user-fullname=CitrOS" \
    --iso-publisher "Koutsie / The CitrOS Project" \
    --bootloaders grub-efi grub-pc \
    --uefi-secure-boot auto \
    --iso-application "CitrOS Hybird" \ > /dev/null

cd ../../

echo "Copying over bashrc..."
mkdir -p -v citros/live-build-buster/config/includes.installer/home/edible/ > /dev/null
cp bashrc citros/live-build-buster/config/includes.installer/home/edible/.bashrc > /dev/null 
chmod +x citros/live-build-buster/config/includes.installer/home/edible/.bashrc > /dev/null

echo "Copying over xinitrc..."
cp xinitrc citros/live-build-buster/config/includes.installer/home/edible/.xinitrc > /dev/null
chmod +x citros/live-build-buster/config/includes.installer/home/edible/.xinitrc > /dev/null

# This needs to be refactored, maybe an after first boot installer?
echo "Copying over wallpaper..."
mkdir -p -v citros/live-build-buster/config/includes.installer/home/edible/wallpapers/ > /dev/null   
cp assets/CitrOS-default.png citros/live-build-buster/config/includes.installer/home/edible/wallpapers/ > /dev/null
mkdir -p -v citros/live-build-buster/config/includes.installer/usr/share/lxqt/themes/debian/ > /dev/null   
cp assets/CitrOS-default.png citros/live-build-buster/config/includes.installer/usr/share/lxqt/themes/debian/

echo "Setting nameserver..."
mkdir -p -v citros/live-build-buster/config/includes.installer/etc/ > /dev/null
echo -e "# CitrOS defaults to Mullvad's DNS.\n193.138.218.74" > citros/live-build-buster/config/includes.installer/etc/resolv.conf # We use Mullvad's  DNS.

# Not used AON.
#echo "Copying over sowm's hook file for chroot build..."
#mkdir -p -v citros/live-build-buster/config/hooks/live/ > /dev/null
#mkdir -p -v citros/live-build-buster/config/hooks/normal/ > /dev/null
#cp hooks.chroot.live/sowm.hook.chroot citros/live-build-buster/config/hooks/live/0500-sowm.hook.chroot > /dev/null
#cp hooks.chroot.live/sowm.hook.chroot citros/live-build-buster/config/hooks/normal/0500-sowm.hook.chroot > /dev/null
#chmod +x citros/live-build-buster/config/hooks/live/0500-sowm.hook.chroot
#chmod +x citros/live-build-buster/config/hooks/normal/0500-sowm.hook.chroot

echo "Copying over customized build files..."
cp readyconfig/build citros/live-build-buster/config/ > /dev/null
cp live.list.chroot citros/live-build-buster/config/package-lists/ > /dev/null
cp live.list.chroot citros/live-build-buster/config/package-lists/normal.list.chroot > /dev/null

echo "Copying over installer banner..."
mkdir -p -v citros/live-build-buster/config/includes.installer/usr/share/graphics/ > /dev/null
cp assets/banner.png citros/live-build-buster/config/includes.installer/usr/share/graphics/logo_debian.png > /dev/null
cp assets/banner.png citros/live-build-buster/config/includes.installer/usr/share/graphics/logo_debian_dark.png > /dev/null
cd citros/live-build-buster/ 

#FIXME: Add this functionality.
#echo "Copying over preseed file..."
#mkdir -p -v citros/live-build-buster/config/includes.installer/ > /dev/null
#cp readyconfig/preseed.cfg citros/live-build-buster/config/includes.installer/preseed.cfg > /dev/null

#echo "Copying over grub's config..."
#mkdir -p -v citros/live-build-buster/config/bootloaders/grub-pc/ > /dev/null
#cp bootloaders/grub-pc/grub.cfg citros/live-build-buster/config/bootloaders/grub-pc/ > /dev/null # Copy over Grub config 
# FIXME: I have no clue how to get this to work.
# EDIT: I have a slight hint on how to maybe get this to work.
# EDIT2: I need a splash and some time. And a cup or ten of coffee.

echo "Adding boot time scripts, if any..."
mkdir -p -v citros/live-build-buster/config/includes.installer/lib/live/config/ > /dev/null
cp boot-time* citros/live-build-buster/config/includes.installer/lib/live/config/ > /dev/null 2>&1 # We're silencing because most people don't have boot time scripts.
# NOTE: This is not used as of now.

echo "Copying over build identifiers..."
# FIXME: Very dirty way of doing this
mkdir -p -v citros/live-build-buster/config/includes.installer/etc/ > /dev/null

echo PRETTY_NAME='"CitrOS GNU/Linux"' > citros/live-build-buster/config/includes.installer/etc/os-release
echo NAME='"CitrOS Debian GNU/Linux"' >> citros/live-build-buster/config/includes.installer/etc/os-release
echo VERSION_ID='"10"' >>citros/live-build-buster/config/includes.installer/etc/os-release
echo VERSION='"10 (buster)"' >> citros/live-build-buster/config/includes.installer/etc/os-release
echo VERSION_CODENAME=buster >> citros/live-build-buster/config/includes.installer/etc/os-release
echo ID=debian >> citros/live-build-buster/config/includes.installer/etc/os-release
echo HOME_URL='""' >>citros/live-build-buster/config/includes.installer/etc/os-release
echo SUPPORT_URL='""' >> citros/live-build-buster/config/includes.installer/etc/os-release
echo BUG_REPORT_URL='""' >> citros/live-build-buster/config/includes.installer/etc/os-release
echo "$osrelease" > citros/live-build-buster/config/includes.installer/etc/os-release
echo "$buildt" > citros/live-build-buster/config/includes.installer/etc/CitrOSBuild
echo "Configuration done, starting build..."

# Clean it.
echo "Cleaning..."
sudo lb clean --purge > /dev/null &
spinner

# Build it.
echo "Building ISO with custom installer..."
time sudo lb build > /dev/null 2>&1 &
spinner

# The build is done, notify the user.
printf '\e[?5h'
sleep 1
printf '\e[?5l'
sleep 1
printf '\e[?5h'
sleep 1
printf '\e[?5l'

echo "Done!"
