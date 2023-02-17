# Custom OpenBSD 7.2 Image Builder

The `build72.sh` build script builds a custom `install72.iso` image from the official one.

The machine running this script should be running OpenBSD 7.2 and have the same architecture as the target for the custom image.

## Templates

Each template may contain a `ramdisk.sh` script to customize the installation ramdisk and an `image.sh` script to customize the installation image. Either script can be omitted. Be sure to make them executable.

The provided templates include both of these scripts. The scripts are documented and contain many examples of what you can do and how to do it.

## Example Usage

The build script must be run as root.

```sh
# Display all parameter descriptions and instructions.
build72.sh --help

# Build a release using the "example" template.
build72.sh --template example
```

## Changes

- The build script now handles compressed bsd.rd (ramdisk compression was added
  at some point between OpenBSD 6.6. and 7.2)
- The build script does `set -e` to handle subtle errors not caught by default

## License

This work is available under a BSD license as described in the LICENSE.txt file.
