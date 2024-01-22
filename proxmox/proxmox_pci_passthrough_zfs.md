<!-- ABOUT THE PROJECT -->
## ZFS CMDLINE

If you want to passtrought pcie on zfs setup you need to edit cmdline in your kernel.

### Configuration

1. Edit cmdline file
```sh
vi /etc/kernel/cmdline
```
2. Put parameters that you need
```sh
console=tty0 amd_iommu=on pcie_acs_override=downstream,multifunction video=vesafb:off,efifb:off video=efifb:off pci=noaer
```
