# OpenBSD 6.5 Builder Template

First, build a release using this template or use a pre-built builder release to set up a build machine. Then, log in to the machine and start building.

The password on the pre-built image for the `puffy` account is `puffy`, and the password for the `root` account is `root`.

```sh
# Log in to the build machine as puffy...

# Build a release using the "example" template.
doas -u root /home/puffy/build65.sh --template example --mirror https://cdn.openbsd.org/pub/OpenBSD

# Clear out the images if necessary.
doas -u root rm -rf /home/puffy/images

# Clear out the sources if necessary.
doas -u root rm -rf /home/puffy/sources
```

Note that the template lets OpenBSD automatically partition the drive. This means the drive will need to be around 10-15 GB to provide a reasonable amount of free space on the `/home` partition. Of course, you can always customize the template or the machine after installation if this is problematic.
