#!/bin/sh
# Use this script to customize the ramdisk image and its contents before it's
# built. The current working directory will be the root directory of the ramdisk
# image.
#
# Useful variables:
# $ARCH = the architecture of the machine and resulting image
# $RELEASE = the OpenBSD release of the machine and resulting image
# $REL = the OpenBSD release of the machine and resulting image without periods
# $ROOT_DIR = the absolute path to root of the build scripts
# $RAMDISK_DIR = the absolute path to the custom ramdisk
# $TEMPLATE_DIR = the absolute path to the template including this script

# Add auto_install.conf for autoinstall(8).
cp "${TEMPLATE_DIR}/auto_install.conf" .
