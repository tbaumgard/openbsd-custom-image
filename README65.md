# Custom OpenBSD 6.5 Image Builder

The `build65.sh` build script builds a custom `install65.iso` image from the official one.

The machine running this script should be running OpenBSD 6.5 and have the same architecture as the target for the custom image.

## Templates

Each template may contain a `ramdisk.sh` script to customize the installation ramdisk and an `image.sh` script to customize the installation image. Either script can be omitted. Be sure to make them executable.

The provided templates include both of these scripts. The scripts are documented and contain many examples of what you can do and how to do it.

## Example Usage

The build script must be run as root.

```sh
# Display all parameter descriptions and instructions.
build65.sh --help

# Build a release using the "example" template.
build65.sh --template example --mirror https://cdn.openbsd.org/pub/OpenBSD
```

## License

This work is available under a BSD license as described in the LICENSE.txt file.
