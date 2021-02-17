# zfs kernel builder

---

## brings you the joy of built-in kernels with a single command!

More of a series of commands than a proper script, but it works

- build specified zfs package (has not been tested with <2.0)
- build specified kernel (v5.x.x only)
- compile zfs modules into kernel
- Renders zfs-initramfs, zfs-dracut packages unnecessary
- Tracks stock kernel config - should work fine!

## Written for debian and derivatives (can still compile zfs rpms, though)

To run - retrieve build dependencies:

```
% chmod +x *.sh
% ./install-build-requirements.sh
```

invoke script with $ZFS_VERSION $KERNEL_VERSION and $MAKECOMMAND (optional)

```
% ./build-zfs-kernel.sh 2.0.3 5.10.17 modconfig
```

Tested Ubuntu 20.04 and 20.10.

Please fork or submit PRs.
