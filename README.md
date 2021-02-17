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

#### \*(can still compile zfs rpms, though)

To run - retrieve build dependencies:
```
% chmod +x *.sh
% ./install-build-requirements.sh
```

invoke script with $ZFS_VERSION $KERNEL_VERSION and $MAKECOMMAND (optional)
```
% ./build-zfs-kernel.sh 2.0.3 5.10.17 modconfig
```

Latest zfs releases: https://github.com/openzfs/zfs/releases
List of compatible kernels:  https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/
Make commands (not required) - discussion: https://www.reddit.com/r/linux/comments/1aq1vg/linux_protip_if_youre_building_a_custom_local/ 

Tested Ubuntu 20.04 and 20.10.

Please fork or submit PRs.
