

# ProxmoxGpuPassthrough
# ---------------
Redirect your GPU to windows vm, only AMD + NVIDIA


# Edit entry
# ---------------
  * grub
  vi /etc/default/grub
  ..
  GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on"
  ..
  
  * zfs
  vi /etc/kernel/cmdline
  root=ZFS=rpool/ROOT/YOUR-POOL-NAME boot=zfs nofb console=tty0 amd_iommu=on pcie_acs_override=downstream,multifunction video=vesafb:off,efifb:off video=efifb:off

# Iommu options
# ---------------
sudo echo "options vfio_iommu_type1 allow_unsafe_interrupts=1" > /etc/modprobe.d/iommu_unsafe_interrupts.conf
sudo echo "options kvm allow_unsafe_assigned_interrupts=1 ignore_msrs=1" > /etc/modprobe.d/kvm.conf

# Blacklist drivers
# ---------------
sudo echo "blacklist radeon" >> /etc/modprobe.d/blacklist.conf
sudo echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
sudo echo "blacklist nvidia" >> /etc/modprobe.d/blacklist.conf

# Virtual Functions
# ---------------

lspci -n -s 01:00

*Sample Output
01:00.0 0108: 1987:5008 (rev 01)

echo "options vfio-pci ids=1987:5008 disable_vga=1"> /etc/modprobe.d/vfio.conf
sudo update-initramfs -u
sudo reboot now

# Download VirtIO drivers
# ---------------
cd /var/lib/vz/template/iso/
wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso

# Create VM
# ---------------

Hardware configuration:
BIOS: OVMF (UEFI)
MACHINE: q35
SCSI Controller: VirtIO SCSI single
CD/DVD Drive ide1 windows.iso
CD/DVD Drive ide2 virtio-win.iso

Install Windows
Install VirtIO drivers
Set static ip
Download and login to Geforce experience
Install vnc server or use RDP 
Check connection from another device.

// VNC: https://www.tightvnc.com/download/2.8.59/tightvnc-2.8.59-gpl-setup-64bit.msi
// RDP WITHOUT PASS: https://harshasnmp.wordpress.com/2018/03/21/windows-allow-remote-desktop-access-with-blank-passwords/

Shutdown VM.

# Add GPU
# ---------------

Your VM -> Hardware -> Add -> PCI Device -> Nvidia

*REMINDER
lspci -n -s 01:00

# Download and use ROM file
# ---------------
https://www.techpowerup.com/vgabios/

cd /usr/share/kvm/
wget -O rtx2080.rom https://www.techpowerup.com/vgabios/215184/Gigabyte.RTX2080Super.8192.190731.rom

cd /etc/pve/qemu*
vi <VM ID>.conf
hostpci0: 01:00,pcie=1,romfile=<YOUR GPU>.rom,x-vga=1
vga: none:

# Start VM
# ---------------

Connect to vm by rdp/vnc check gpu in your devices. 

# EXTRAS
# ---------------

Use moonlight to stream your games over ethernet https://github.com/moonlight-stream

#REF:
https://www.reddit.com/r/VFIO/comments/ay5o0j/success_rtx_2080ti_wsli_threadripper2_on/
https://www.reddit.com/r/homelab/comments/b5xpua/the_ultimate_beginners_guide_to_gpu_passthrough/
https://pve.proxmox.com/wiki/Pci_passthrough
