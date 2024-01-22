<!-- ABOUT THE PROJECT -->
## Nvidia offloading

Below you have example how to combine NVIDIA and Intel-integra display outputs.

<!-- GETTING STARTED -->
## Getting Started

We start from absolute zero I'm assume that you installed Debian minimal server.

### Prerequisites

* modify sources.list

```sh
sed -i -r '/^\s*$/d' sources.list && sed -i s/$/contrib non-free/ sources.list
```
or
```sh
distro=`grep -Po 'VERSION="[0-9]+ \(\K[^)]+' /etc/os-release`
echo "deb http://deb.debian.org/debian $distro main contrib non-free" >> /etc/apt/sources.list
```

* install prerequisites
```sh
apt-get update && apt-get install xorg x11-xserver-utils sudo firmware-misc-nonfree nvidia-detect && apt-get install $(nvidia-detect | grep nvidia-)
```

### Configuration

We need to create simple XORG configuration to do that create xorg.conf in X11 folder.

```sh
sudo vi /etc/X11/xorg.conf
```
Below XORG configuration for this 3 monitor example.

| screen 1 | screen 2 | screen 3 |
|  :---:  |  :---:  |   :---:  |
| INTEL  | NVIDIA  | NVIDIA  |


```sh
Section "Device"
    Identifier  "nouveau"
    Driver      "nvidia"
    BusID       "PCI:1:0:0" # see man lspci
EndSection

Section "Screen"
    Identifier "nouveau"
    Device "nouveau"
EndSection

Section "Device"
    Identifier  "intel"
    Driver      "modesetting"
EndSection

Section "Screen"
    Identifier "intel"
    Device "intel"
EndSection
```

Save and reboot

```sh
sudo reboot now
```

Finaly use xrand to combine sources

```sh
xrandr --setprovideroutputsource modesetting NVIDIA-0 
xrandr --auto
```

Check your displays

```sh
xrandr -q | grep -w "connected"
```

You will get something similar to:

```
DVI-I-1 connected 2560x1080+2560+0 (normal left inverted right x axis y axis) 673mm x 284mm
HDMI-0 connected 2560x1080+5120+0 (normal left inverted right x axis y axis) 673mm x 284mm
HDMI-1-1 connected 2560x1080+0+0 (normal left inverted right x axis y axis) 673mm x 284mm
```

At the end you need to create your custom script using output from previous command. 

Something like this:
```sh
xrandr \
--output DVI-I-1 --mode 2560x1080 --pos 2560x0 --rotate normal \
--output HDMI-0 --mode 2560x1080 --pos 5120x0 --rotate normal \
--output HDMI-1-1 --mode 2560x1080 --pos 0x0 --rotate normal
```

### Usage

You need to execute this 3 scripts evry time after boot.

```sh
xrandr --setprovideroutputsource modesetting NVIDIA-0 
xrandr --auto
xrandr \
--output DVI-I-1 --mode 2560x1080 --pos 2560x0 --rotate normal \
--output HDMI-0 --mode 2560x1080 --pos 5120x0 --rotate normal \
--output HDMI-1-1 --mode 2560x1080 --pos 0x0 --rotate normal
```

### REF
https://wiki.debian.org/NvidiaGraphicsDrivers

https://askubuntu.com/questions/593938/how-to-run-both-intel-and-nvidia-graphics-card-driver-on-dual-monitor-setup

http://us.download.nvidia.com/XFree86/Linux-x86/319.12/README/randr14.html
