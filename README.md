# Custom OpenBSD Image Builder

These relatively simple build scripts make it easy to create custom `installXX.iso` images from the official ones, leveraging existing functionality whenever possible. This allows things such as:

- Adding auto_install.conf and auto_upgrade.conf files directly to the image
- Adding custom siteXX.tgz files directly to the image
- Patching the installer program on the image so that scripts can be run to prepare *before* an unattended installation or upgrade
- Pretty much anything else

The build scripts must be run on OpenBSD. Each script corresponds to a specific release of OpenBSD and comes with a `READMEXX.md` file.

Downloading source files and creating images can take a lot of space. How much is needed depends on how many images will be created and exactly what they'll contain, but 2-3 GBs of free space is a pretty reasonable minimum to start with.

## Templates

Templates are the means by which an official `installXX.iso` image is customized. There are example and builder templates for each supported version and for some architectures.

The example template contains a number of files to get you started creating your own template, and the builder template is used to build images that take all or most of the work out of setting up a build machine. Looking at both templates is the best way to figure out how things work.

Read the specific `READMEXX.md` file for your target release for more information.

## Example Usage

Simple usage instructions are included below. More detailed instructions and notes are contained in the `READMEXX.md` files.

```sh
# Display all parameter descriptions and instructions.
buildXX.sh --help

# Build a release using the "example" template.
buildXX.sh --template example --mirror https://cdn.openbsd.org/pub/OpenBSD
```

## Build Images

There are pre-built installation images available that take all or most of the work out of setting up a build machine. These are an easy and quick way to get started.

## License

This work is available under a BSD license as described in the LICENSE.txt file.
