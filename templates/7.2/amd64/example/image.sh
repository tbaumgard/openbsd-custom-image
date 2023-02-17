#!/bin/sh
# Use this script to customize the image and its contents before it's built. The
# current working directory will be the root directory of the image.
#
# Useful variables:
# $ARCH = the architecture of the machine and resulting image
# $RELEASE = the OpenBSD release of the machine and resulting image
# $REL = the OpenBSD release of the machine and resulting image without periods
# $ROOT_DIR = the absolute path to root of the build scripts
# $IMAGE_DIR = the absolute path to the custom image
# $TEMPLATE_DIR = the absolute path to the template including this script

# Create a temporary directory used to create the siteXX.tgz file.
TEMP_SITE="$(mktemp -p "${ROOT_DIR}" -d site.XXXXXX)"

# Copy the existing siteXX files because they'll be customized below.
cp -Rp "${TEMPLATE_DIR}/site${REL}/." "${TEMP_SITE}"

# Fix file and directory ownership. Proper ownership should really be set on the
# files and directories in the site72 directory instead, but this is done here
# since the development of this template isn't always done on OpenBSD.
chown root:wheel "${TEMP_SITE}/usr"
chown root:wheel "${TEMP_SITE}/usr/local"
chown root:wheel "${TEMP_SITE}/usr/local/bin"
chown root:bin "${TEMP_SITE}/usr/local/bin/test.sh"

# Package up the siteXX.tgz file and clean up.
tar czf "${RELEASE}/${ARCH}/site${REL}.tgz" -C "${TEMP_SITE}" .
rm -rf "${TEMP_SITE}"

# Alternatively, if developing on OpenBSD and the proper ownership for the
# siteXX files and directories is set using chown, this entire script could be
# reduced to the following:
# tar czf "${RELEASE}/${ARCH}/site${REL}.tgz" -C "${TEMPLATE_DIR}/site{$REL}" .
