## SERVER

```
apt-get install targetcli-fb
apt-get install dbus
apt-get install bus


systemctl enable bus
systemctl enable target

mkdir /mnt/data
mount /dev/sdb /mnt/data

blkid -s UUID -o value | tail -1 >> /etc/fstab

```



## Client


### Umounting

```
vi aaamount
```

```sh
#!/bin/sh

#
# aaaumount initscript
#
### BEGIN INIT INFO
# Provides:          aaaumount
# Required-Start:    $local_fs $remote_fs
# Required-Stop:     $remote_fs
# Default-Start:     S
# Default-Stop:      0 1 6
# Short-Description: umounts cifs shares
# Description:       This script unmounts cifs shares
### END INIT INFO

case "$1" in
 stop)
            umount /mnt/data
esac
```
```
vi /etc/init.d/aaaumount
chmod 755 /etc/init.d/aaaumount
ln -s /dev/null aaaumount.service
ln -s /etc/init.d/aaaumount /etc/rc0.d/K01aaaumount
ln -s /etc/init.d/aaaumount /etc/rc6.d/K01aaaumount
systemctl enable aaaumount.service
```

### Mounting

```
crontab -e
```
```
@reboot iscsiadm -m node -T iqn.2021-11.COM.EXAMPLE:target-data-block -l && sleep 30 && mount /dev/sdb /mnt/data
```
