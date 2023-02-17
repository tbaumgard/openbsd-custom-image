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

# Add auto_install.conf and auto_upgrade.conf for autoinstall(8).
cp "${TEMPLATE_DIR}/auto_install.conf" .
cp "${TEMPLATE_DIR}/auto_upgrade.conf" .

# Patch the installer to allow for automatic installation prep.
patch -p1 < "${TEMPLATE_DIR}/install.sub.patch"
rm install.sub.orig

# Add auto_install_prep.site and auto_upgrade_prep.site scripts for automatic
# installation prep.
cp "${TEMPLATE_DIR}/auto_install_prep.site" .
cp "${TEMPLATE_DIR}/auto_upgrade_prep.site" .
