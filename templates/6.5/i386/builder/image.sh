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

# Remove the sets that aren't necessary for the builder. This will decrease the
# size of the resulting image.
(
	cd "${RELEASE}/${ARCH}"
	rm comp*.tgz game*.tgz xbase*.tgz xshare*.tgz xfont*.tgz xserv*.tgz
)

# Create a temporary directory used to create the siteXX.tgz file.
TEMP_SITE="$(mktemp -p "${ROOT_DIR}" -d site.XXXXXX)"

# Copy the existing siteXX files because they'll be customized below.
cp -Rp "${TEMPLATE_DIR}/site${REL}/." "${TEMP_SITE}"

# Copy over all the templates specific to the release and architecture.
mkdir -p "${TEMP_SITE}/home/puffy/templates/${RELEASE}/${ARCH}"
cp -p "${ROOT_DIR}/build${REL}.sh" "${TEMP_SITE}/home/puffy"
cp -Rp "${ROOT_DIR}/templates/${RELEASE}/${ARCH}/." "${TEMP_SITE}/home/puffy/templates/${RELEASE}/${ARCH}"

# Fix file and directory ownership. Proper ownership should really be set on the
# files and directories in the site65 directory instead, but this is done here
# since the development of this template isn't always done on OpenBSD.
chown root:wheel "${TEMP_SITE}/etc"
chown root:wheel "${TEMP_SITE}/etc/doas.conf"
chown root:wheel "${TEMP_SITE}/home"
chown root:wheel "${TEMP_SITE}/usr"
chown root:wheel "${TEMP_SITE}/usr/local"
chown root:wheel "${TEMP_SITE}/usr/local/sbin"

# Package up the siteXX.tgz file and clean up.
tar czf "${RELEASE}/${ARCH}/site${REL}.tgz" -C "${TEMP_SITE}" .
rm -rf "${TEMP_SITE}"
