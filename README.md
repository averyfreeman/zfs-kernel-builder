# zfs kernel builder

---

## brings you the joy of built-in kernels with a single command!

More of a series of commands than a proper script, but it works

- build specified zfs package (has not been tested with <2.0)
- build specified kernel (v5.x.x only)
- compile zfs modules into kernel
- Renders zfs-initramfs, zfs-dracut packages unnecessary
- Tracks stock kernel config - should work fine!

## Kernel portion written for debian and derivatives\*

#### \*(can be modified to compile zfs rpms, but not kernels)

To run - retrieve build dependencies:
```
% chmod +x *.sh
% ./install-build-requirements.sh
```

invoke script with $ZFS_VERSION $KERNEL_VERSION and $MAKECOMMAND (optional)
Example:
```
% ./build-zfs-kernel.sh 2.0.3 5.10.17 modconfig
```

Or run without any make command - e.g.:
```
% ./build-zfs-kernel.sh 2.0.3 5.10.17
```
The above two arguments, $ZFS_VERSION and $KERNEL_VERSION are required.

### Resources:

Find the versions you'd like to use with the builder:

- Latest zfs releases: https://github.com/openzfs/zfs/releases
- List of compatible kernels:  https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/
- Make commands (not required) - discussion: https://www.reddit.com/r/linux/comments/1aq1vg/linux_protip_if_youre_building_a_custom_local/ 

Tested Ubuntu 20.04 through 21.04, Debian 10 and 11-testing repo (aka 11-lite™).

Released under [WTFPL](http://www.wtfpl.net/) Please fork or submit PRs.
