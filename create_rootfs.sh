#!/bin/bash
set -e

# https://stackoverflow.com/a/246128
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOTFS_DIR=$SCRIPT_DIR/rootfs

rm -rf $ROOTFS_DIR
mkdir $ROOTFS_DIR
mkdir -p $SCRIPT_DIR/secrets

#qemu-debootstrap --arch=arm64 bullseye $ROOTFS_DIR http://archive.raspberrypi.org/debian
qemu-debootstrap --arch=armhf bullseye $ROOTFS_DIR http://archive.raspbian.org/raspbian/

cp -r $SCRIPT_DIR/os/* $ROOTFS_DIR

chroot $ROOTFS_DIR cat /etc/os-release | head -n1
chroot $ROOTFS_DIR apt-get install -y \
    sudo \
    docker \
    docker-compose \
    git

chroot $ROOTFS_DIR adduser --gecos "" --disabled-password --no-create-home pi
chroot $ROOTFS_DIR chpasswd <<<"pi:raspberry"

chroot $ROOTFS_DIR cd /home/pi
chroot $ROOTFS_DIR docker-compose -f /home/pi/docker-compose.yml up

dd if=$ROOTFS_DIR of=$SCRIPT_DIR/image.img bs=1m
