#!/bin/sh
set -eu

# Image informations.
name="archlinux-aur-freefem"
author="Guillaume_Dollé"
dist=archlinux
tag=latest
entrypoint=

pkg_list="
base-devel
sudo 
curl 
binutils 
make 
gcc 
pkg-config 
fakeroot 
go 
git
"

pkg_aur_list="
freefem
"

########################################
# BUILDAH HELPER FUNCTIONS.
########################################

# Print custom messages with colors.
MSG() 
{
    bold=$(tput bold)
    red=$(tput setaf 1)
    green=$(tput setaf 2)
    yellow=$(tput setaf 3)
    blue=$(tput setaf 4)
    cyan=$(tput setaf 6)
    reset=$(tput sgr0)
    case $1 in
        "STEP")  printf "${bold}${green}[$2]${reset}\n" ;;
        "INFO")  printf "${bold}${cyan}$2${reset}\n" ;;
        "WARN")  printf "${bold}${yellow}$2${reset}\n" ;;
        "ERROR") printf "${bold}${red}$2${reset}\n" ;;
    esac
}
BASE(){ export cont=`buildah from $1`; }
RUN(){  buildah run ${cont} -- "$@"; }
CLEAN(){ buildah rm ${cont}; }
CONF(){ buildah config $@ ${cont}; }
COMMIT(){ buildah commit ${cont} $@; }


########################################
# MAIN RECIPE.
########################################

# Avoid remaining unfinished containers.
trap_exit(){
MSG     "STEP" "Remove container..."
CLEAN
}
trap trap_exit EXIT


BASE    ${dist}:${tag}

MSG     "STEP" "Create build user..."
RUN     useradd -m -d /build build 
RUN     usermod -aG wheel build
RUN     passwd -d build

MSG     "STEP" "Updating ${dist} packages..."
RUN     pacman -Syu --noconfirm
RUN     pacman -S --noconfirm ${pkg_list}

MSG     "STEP" "Install yay from AUR..."
RUN     sudo -iu build curl -o PKGBUILD -L "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=yay"
RUN     sudo -iu build makepkg -s
RUN     bash -c 'cd /build && yes | pacman -U `find -name yay*.tar.zst`'

MSG     "WARN" "Enable 'wheel' sudoers group..."
RUN     bash -c 'sed -i "s/# \%wheel ALL=(ALL) NOPASSWD/\%wheel ALL=(ALL) NOPASSWD/g" /etc/sudoers'

MSG     "STEP" "Install yay from AUR..."
RUN     sudo -iu build yay -S --noconfirm ${pkg_aur_list}


MSG     "STEP" "Cleaning containers"

MSG     "INFO" "Clean dist files"
RUN     sudo -iu build yay -Scc --noconfirm

MSG     "INFO" "Remove build user"
RUN     userdel -r build


MSG     "STEP" "Configuring container..."
CONF    --author ${author} --created-by ${author} --label name=${name}
#CONF    --entrypoint ${entrypoint}

MSG     "STEP" "Create OSI image..."
COMMIT  ${name}
