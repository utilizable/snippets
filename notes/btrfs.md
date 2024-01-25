NOTES - BTRFS
======

## 📌 References

- https://wiki.archlinux.org/title/Btrfs
- https://amedeos.github.io/backup/2021/08/18/Use-btrbk-for-backup-on-btrfs.html
- https://medium.com/@inatagan/installing-debian-with-btrfs-snapper-backups-and-grub-btrfs-27212644175f
- https://github.com/Antynea/grub-btrfs / https://github.com/Antynea/grub-btrfs/tree/feature/ubuntu-init

## 💡 Tips

  - Nested subvolumes are skiped - you can use this technique to save space (eg. excluding /var/logs by creating @logs subovlume and attached it into /var/logs),
  - The best option is to have separate boot partition, in a case of error's you can use Antynea/grub-btrfs utility to boot into previous snapshot and preform rollback,
  - `btrbk` give's you posibility to sync. snapshots with remotes,
  - You can boot your snapshot as [systemd-nspawn](https://wiki.archlinux.org/title/Systemd-nspawn#Use_Btrfs_subvolume_as_container_root) container,
