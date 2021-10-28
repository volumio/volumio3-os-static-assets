# Volumio Repository for Static Files

This repository is meant to store binaries, blobs or static dependencies for the [Volumio Build System](https://github.com/volumio/volumio3-os)


## File structure and build notations 

* When necessary, files shall be uploaded for all supported architectures: arm/armv7/armv8/x86/x64
NOTE: For better compatibility, a single arm build (for armv6) is enough, but the same file shall be copied for all remaining arm architectures
* Please adhere to the folder structure in place, in order to keep things tidy
* File name structure is as follow: filename_version_arch
Example:

https://github.com/volumio/static-assets/raw/master/volumio-remote-updater/custom-packages/volumio-remote-updatera/volumio-remote-updater_1.7_amd64.deb

File: volumio-remote-updater
Version: 1.7
Arch: x64