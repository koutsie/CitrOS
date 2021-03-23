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

# Hi, you're reading the "source code" for CitrOS aka my (koutsie) JADD(Just Another Debian Distro).
# This should absolutely not be used in any kind of staging/deployment enviroment!
# Theres ABSOLUTELY NO WARRANTY for ANYTHING included in this repository!
# See LICENCE in the root of this repository.
# Stuff might be broken and WILL be broken, kittens WILL die & everything WILL burn if you decide against the advice above!
#
# Otherwise?
# Please do take a look and do and make a pull request if you see any outstanding issues.


# Functions / Vars

# Yoinked from https://stackoverflow.com/questions/12498304/using-bash-to-display-a-progress-indicator/20369590#20369590 ;^)
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

# NONPRIO: Dirty flash for notify, any better way to do this?
flash()
{
    for  n in {1..8}; do
    printf '\e[?5h'
    sleep 0.8
    printf '\e[?5l'
    sleep 0.8
    done
}
 # Set build date and current username as build identifiers.
 # I know we could set this later but I like to consider the build's start time as the "build date".
 # Feel free to suggest alternatives of course!
bname="koutsie"
buildt=$(date +"Built on %D at %T.%3N by $bname")
buildt=$(echo "echo "$buildt"") # yes. i know i know.

sleep 4

echo "Making root build dir..."
mkdir -p -v citros/live-build-buster > /dev/null
cd citros/live-build-buster/

# Config it.
# Check out "man lb config" ;)
# Some most commonly changed options below, with their associative flags:
#
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
    ­­--binary­images iso \
    --mode debian \
    --debian-installer live \
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
    --bootloaders grub-efi \
    --uefi-secure-boot auto \
    --iso-application "CitrOS Hybird" \ > /dev/null

cd ../../

echo "Making directories..."
mkdir -p -v citros/live-build-buster/config/includes.chroot/etc/ > /dev/null # Live user /etc/
mkdir -p -v citros/live-build-buster/config/includes.installer/etc/ > /dev/null # Yep we're making this folder twice. As of now at least.
mkdir -p -v citros/live-build-buster/config/includes.chroot/home/edible/ > /dev/null # Live user home
mkdir -p -v citros/live-build-buster/config/includes.installer/etc/skel/ > /dev/null # Installer /etc/  |-| Installer home skeleton
mkdir -p -v citros/live-build-buster/config/includes.chroot/usr/share/lxqt/themes/debian/ > /dev/null # Wallpaper dir
mkdir -p -v citros/live-build-buster/config/includes.installer/usr/share/graphics/ > /dev/null # Installer /usr/share |-| Installer banner
mkdir -p -v citros/live-build-buster/config/includes.installer/usr/share/lxqt/themes/debian/ > /dev/null # Installer wallpaper
mkdir -p -v citros/live-build-buster/config/includes.chroot/lib/live/config/ > /dev/null # Boot time scripts [Live user]
mkdir -p -v citros/live-build-buster/config/includes.chroot/etc/ > /dev/null # Build identifier dir [Live user]

echo "Copying over bashrc..."
 # Now I don't know if these two are the same but fuck it, we do it anyways.
 # Please do make a PR to fix this if I'm horribly wrong about how this works.
cp bashrc citros/live-build-buster/config/includes.chroot/home/edible/.bashrc > /dev/null
echo $buildt >> citros/live-build-buster/config/includes.chroot/home/edible/.bashrc > /dev/null # Set builtby & date.
chmod +x citros/live-build-buster/config/includes.chroot/home/edible/.bashrc > /dev/null
# Copy over stuff to the installer(?)
cp bashrc citros/live-build-buster/config/includes.installer/etc/skel/.bashrc > /dev/null
echo $buildt >> citros/live-build-buster/config/includes.installer/etc/skel/.bashrc > /dev/null # Set builtby & date.
chmod +x citros/live-build-buster/config/includes.installer/etc/skel/.bashrc > /dev/null

echo "Copying over xinitrc..."
cp xinitrc citros/live-build-buster/config/includes.chroot/home/edible/.xinitrc > /dev/null
chmod +x citros/live-build-buster/config/includes.chroot/home/edible/.xinitrc > /dev/null
# Copy over stuff to the installer(?)
cp xinitrc citros/live-build-buster/config/includes.installer/etc/skel/.xinitrc > /dev/null
chmod +x citros/live-build-buster/config/includes.installer/etc/skel/.xinitrc > /dev/null

# This needs to be refactored, maybe an after first boot installer?
echo "Copying over wallpaper..."
cp assets/CitrOS-default.svg citros/live-build-buster/config/includes.chroot/usr/share/lxqt/themes/debian/wallpaper.svg > /dev/null
# Test including wallpaper in installed OS.
# This works!
cp assets/CitrOS-default.svg citros/live-build-buster/config/includes.installer/usr/share/lxqt/themes/debian/wallpaper.svg > /dev/null

echo "Setting nameserver..."
echo -e "# CitrOS defaults to Mullvad's DNS.\n193.138.218.74" > citros/live-build-buster/config/includes.chroot/etc/resolv.conf > /dev/null # We use Mullvad's  DNS.

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
cp assets/banner.png citros/live-build-buster/config/includes.installer/usr/share/graphics/logo_debian.png > /dev/null
cp assets/banner.png citros/live-build-buster/config/includes.installer/usr/share/graphics/logo_debian_dark.png > /dev/null

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
cp boot-time* citros/live-build-buster/config/includes.chroot/lib/live/config/ > /dev/null 2>&1 # We're silencing because most people don't have boot time scripts.
# NOTE: This is not used as of now.

echo "Copying over build identifiers..."
# FIXME: Very very dirty way of doing this
# Edit: Moved build identifiers to a os-release file in the root of dev, a bit cleaner but there must be a better way...
# Edit remember to remove the no output tags from these !!
cat os-release > citros/live-build-buster/config/includes.chroot/etc/os-release > /dev/null
cat os-release > citros/live-build-buster/config/includes.installer/etc/os-release > /dev/null
echo "$buildt" > citros/live-build-buster/config/includes.chroot/etc/CitrOSBuild > /dev/null
echo "$buildt" > citros/live-build-buster/config/includes.installer/etc/CitrOSBuild > /dev/null
echo "Configuration done, starting build..."

cd citros/live-build-buster # ???

# Clean it.
echo "Cleaning..."
sudo lb clean --purge > /dev/null &
spinner

# Build it.
echo "Building ISO..."

# FIXME: Fix the actual compile to be in seconds
buildiso () {
    # startcompile="$(date +%s)"
    sudo lb build &
    spinner
}

if buildiso ; then
    # endcompile="$(($(date +%s)-startcompile))"
    echo "Done!"
    # echo "Took ${endcompile} seconds."
else
    flash & # Notify the user
    printf "Build \033[33;5m failed\033[0m, check logs!\n"
fi
