#!/bin/sh
# Build a custom image of the OpenBSD 7.2 release.
#
# Author: Tim Baumgard
# License: BSD (See LICENSE.txt)

# ------------------------------------------------------------------------------

set -e

help() {
	cat <<EOF
Usage: $(basename "$0") [--help] [--mirror https://cdn.openbsd.org/pub/OpenBSD] --template example

--help
Display this help message and exit.

--mirror
URL of an OpenBSD mirror. It should be in the same format used by installurl(5).

--template
Name of the template to use when creating images. This parameter is required.
EOF
}

status() {
	echo "### $1"
}

warning() {
	echo "!!! $1"
}

error() {
	echo "ERROR: $1" >&2
	exit 1
}

# ------------------------------------------------------------------------------

# Defaults for the command-line parameters.
MIRROR="https://cdn.openbsd.org/pub/OpenBSD"

while :; do
	case $1 in
		--help|-h|-\?) help; exit 0 ;;
		--mirror) MIRROR="$2" ;;
		--template) TEMPLATE="$2" ;;
		*) test "${#1}" -gt 0 || break ;;
	esac

	shift 2
done

ROOT_DIR="$(dirname "$(readlink -f "$0")")"
RELEASE="$(uname -r)"
ARCH="$(uname -m)"
REL="${RELEASE%.[0-9]}${RELEASE#[0-9].}"
IMAGES="${ROOT_DIR}/images"
SOURCES="${ROOT_DIR}/sources"
TEMPLATE_DIR="${ROOT_DIR}/templates/${RELEASE}/${ARCH}/${TEMPLATE}"
TEMPLATE_IMAGE="${IMAGES}/${RELEASE}/${ARCH}/${TEMPLATE}/${TEMPLATE}${REL}.iso"

if [ "$(id -u)" != "0" ]; then
	error "This script must be run as root."
fi

if [ -z "${MIRROR}" -o -z "${TEMPLATE}" ]; then
	error "Missing parameter(s). For help and example usage, try: $(basename "$0") --help"
fi

if [ ! -d "${ROOT_DIR}/templates/${RELEASE}/${ARCH}/${TEMPLATE}" ]; then
	error "Template doesn't exist for ${RELEASE} release and ${ARCH} architecture."
fi

printf "- This script uses the /mnt directory. You must unmount any file systems that are currently using this directory.\n\n"
printf "- This script uses vnd0. You must unmount any file systems using vnd0 and unconfigure it before continuing. See vnconfig(8).\n\n"
echo -n "Continue? [y/N] "
read CONTINUE

case "${CONTINUE}" in
	[Yy]*) ;;
	*) exit;;
esac

status "Creating necessary files and directories."
mkdir -p "${SOURCES}/${RELEASE}/${ARCH}"
mkdir -p "${IMAGES}/${RELEASE}/${ARCH}/${TEMPLATE}"
TEMP_IMAGE="$(mktemp -p "${ROOT_DIR}" -d image.XXXXXX)"
TEMP_RAMDISK="$(mktemp -p "${ROOT_DIR}" ramdisk.XXXXXX)"

status "Checking for OpenBSD source files and downloading them if necessary."

set -A OPENBSD_SOURCES \
	"${RELEASE}/${ARCH}/SHA256.sig" \
	"${RELEASE}/${ARCH}/install${REL}.iso"

for OPENBSD_SOURCE in ${OPENBSD_SOURCES[@]}; do
	if [ ! -f "${SOURCES}/${OPENBSD_SOURCE}" ]; then
		ftp -o "${SOURCES}/${OPENBSD_SOURCE}" "${MIRROR}/${OPENBSD_SOURCE}"

		if [ $? -ne 0 ]; then
			error "Download failed for ${MIRROR}/${OPENBSD_SOURCE}"
		fi
	fi
done

status "Verifying OpenBSD source files."

for OPENBSD_SOURCE in ${OPENBSD_SOURCES[@]}; do
	# Ignore files that weren't downloaded.
	if [ ! -f "${SOURCES}/${OPENBSD_SOURCE}" ]; then
		continue
	fi

	if [ "${OPENBSD_SOURCE#*SHA256}" == "${OPENBSD_SOURCE}" ]; then
		(
			cd "${SOURCES}/$(dirname "${OPENBSD_SOURCE}")"

			signify -C \
				-p "/etc/signify/openbsd-${REL}-base.pub" \
				-x "SHA256.sig" \
				"$(basename "${OPENBSD_SOURCE}")"

			if [ $? -ne 0 ]; then
				echo "Verification failed for ${MIRROR}/${OPENBSD_SOURCE}. The file should be deleted unless you manually downloaded or added it to the sources."
				echo -n "Continue building? [y/N] "
				read CONTINUE

				case "${CONTINUE}" in
					[Nn]*) exit 1;;
				esac
			fi
		)
	fi
done

status "Mounting and copying the source image."
vnconfig vnd0 "${SOURCES}/${RELEASE}/${ARCH}/install${REL}.iso"
mount -t cd9660 /dev/vnd0c /mnt
cp -Rp /mnt/. "${TEMP_IMAGE}"
umount /mnt
vnconfig -u vnd0

status "Mounting the new ramdisk image."
rd="${TEMP_IMAGE}/${RELEASE}/${ARCH}/bsd.rd"
rd_compressed=false
case "$(file "${rd}")" in
*'gzip compressed data'*)
  rd_compressed=true
  gzip -dc < "${rd}" > "${rd}.tmp"
  mv "${rd}.tmp" "${rd}"
  ;;
*)
  ;;                        
esac
rdsetroot -x "${TEMP_IMAGE}/${RELEASE}/${ARCH}/bsd.rd" "${TEMP_RAMDISK}"
vnconfig vnd0 "${TEMP_RAMDISK}"
mount /dev/vnd0a /mnt

if [ -x "${TEMPLATE_DIR}/image.sh" ]; then
	status "Calling the template image script."

	(
		export ARCH="${ARCH}"
		export RELEASE="${RELEASE}"
		export REL="${REL}"
		export ROOT_DIR="${ROOT_DIR}"
		export IMAGE_DIR="${TEMP_IMAGE}"
		export TEMPLATE_DIR="${TEMPLATE_DIR}"
		cd "${TEMP_IMAGE}"
		"${TEMPLATE_DIR}/image.sh"
	)
elif [ -f "${TEMPLATE_DIR}/image.sh" ]; then
	warning "A template image script was found but it's not executable."
fi

if [ -x "${TEMPLATE_DIR}/ramdisk.sh" ]; then
	status "Calling the template ramdisk script."

	(
		export ARCH="${ARCH}"
		export RELEASE="${RELEASE}"
		export REL="${REL}"
		export ROOT_DIR="${ROOT_DIR}"
		export RAMDISK_DIR=/mnt
		export TEMPLATE_DIR="${TEMPLATE_DIR}"
		cd /mnt
		"${TEMPLATE_DIR}/ramdisk.sh"
	)
elif [ -f "${TEMPLATE_DIR}/ramdisk.sh" ]; then
	warning "A template ramdisk script was found but it's not executable."
fi

status "Unmounting and finalizing the new ramdisk image."
umount /mnt
vnconfig -u vnd0
rdsetroot "${TEMP_IMAGE}/${RELEASE}/${ARCH}/bsd.rd" "${TEMP_RAMDISK}"
if [ "${rd_compressed}" == "true"]; then
  gzip < "${rd}" > "${rd}.tmp"
  mv "${rd}.tmp" "${rd}"
fi

status "Creating the image."
mkhybrid -a -R -T -L -l -d -D -N -o "${TEMPLATE_IMAGE}" -v -v \
	-A "OpenBSD/${ARCH}	${RELEASE} Install CD" \
	-P "Copyright (c) $(date +%Y) Theo de Raadt, The OpenBSD project" \
	-p "Theo de Raadt <deraadt@openbsd.org>" \
	-V "OpenBSD/${ARCH}	${RELEASE} Install CD" \
	-b ${RELEASE}/${ARCH}/cdbr -c ${RELEASE}/${ARCH}/boot.catalog \
	"${TEMP_IMAGE}"

status "Removing temporary files."
rm -rf "${TEMP_IMAGE}"
rm -f "${TEMP_RAMDISK}"

status "Done! The image is located at ${TEMPLATE_IMAGE}"
