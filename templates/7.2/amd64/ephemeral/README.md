# OpenBSD Ephemeral Template

This template is an experiment in creating single-use installations. This is done by using full-disk encryption secured by a keydisk that is erased the first time the system is booted. To be clear, this means that system will only be "ephemeral" if nobody retrieves the keydisk data between the time the system is installed and the first boot.

The drive used is `sd0`. The password for the `puffy` account is `puffy`, and the password for the `root` account is `root`. Of course, these can be customized in the template.
