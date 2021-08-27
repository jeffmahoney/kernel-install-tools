# Kernel Installation Tools

This project contains a few useful scripts to be used primarily by users
building their own kernels outside of their distribution's package management
system.  Most distributions that enable kernels for UEFI Secure Boot have
support for it integrated into the build rules for their kernel packages
but these rules tend to be either inaccessible for direct use or overly
complicated for the simple case of building a kernel for use only on
local systems.

## Dependencies

In order to operate properly, this tool has some dependencies on other tools:

* `openssl`
* `pesign`
* `certutil`
* `pk12util`

On SLE/OpenSUSE, these tools can be found in the `openssl`, `pesign`,
and `mozilla-nss-tools` packages.

## sbtool-keygen

`sbtool-keygen` is used to generate a key suitable for
use in signing kernel modules *and* signing the kernel itself.

Typical usage:

	$ sbtool-keygen /path/to/certificate


## sbtool-sign-kernel

`sbtool-sign-kernel`  is used to prepare the
kernel for use in a Secure Boot environment. It performs several checks
to ensure the signing key is appropriately configured, signs the kernel,
and writes it to the destination.

Typical usage:

	# sbtool-sign-kernel -e arch/x86/boot/bzImage
	/boot/vmlinuz-5.14-kvmsmall /path/to/certificate

The paths to the input and output files are the only required
arguments. If the path to the certificate is omited, the tool will
attempt to locate it via the `CONFIG_MODULE_SIG_KEY` kernel configuration
option. The current working directory and the directory hierarchy where
the source kernel is located will be checked for the presence of a
`.config` file.

The `-e|--enroll` option is used to automatically call `sbtool-enroll-key`
to queue the public component of the signing key for enrollment with
the system MOK. Root privileges are required to copy the certificate
into place and to queue it for enrollment.

The `-q|--quiet ` option may be used to perform the operations silently
unless there are fatal errors. Missing dependencies will cause the tool
to exit successfully.

## sbtool-enroll-key

`sbtool-enroll-key` is used to queue the public
component of the signing key for enrollment in the system MOK (Machine
Owner Key) database at next reboot. The EFI shim will prompt for a
password. The root password active when the tool was invoked will be
used. If the key is already enrolled or queued for enrollment, the tool
exits successfully.  A copy of the certificate will be installed into
/etc/uefi/certs/ using the short fingerprint of the certificate
as the file name.

Typical usage:

	# sbtool-enroll-key /path/to/certificate

The `-q|--quiet ` option may be used to perform the operations silently
unless there are fatal errors. Missing dependencies will cause the tool
to exit successfully.

## installkernel

`/sbin/installkernel` is used by the kernel build system
during `make install` to copy the kernel and other files into place,
generate the initramfs, and update the bootloader with the new kernel. If
`sbtool-sign-kernel` is available, it will be invoked to sign the kernel
using the key used to sign the modules for the kernel being installed. It
is called with the `-q` and -`e` options. If the kernel cannot be signed
for any reason, the kernel is copied into place instead.

It is important to note that while the kernel build environment will
create a key for itself to sign its own modules if none is provided,
the configuration of that key is insufficient for signing the kernel
for use with Secure Boot and it will not be used.

If the signing key is available and suitable, the automatic invocation of
`sbtool-sign-kernel -q -e` means that the process of installing a kernel
that works with Secure Boot should involve no additional effort beyond
copying the key into place.
