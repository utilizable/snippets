QEMU - WINDOWS
============
All the necessary elements to fully configure portable QEMU HV from the CLI.

#### requirements
- [7zip](https://winget.run/pkg/7zip/7zip) - needed to extract qemu package.

#### optional-requirements
- [powershell 7](https://github.com/PowerShell/PowerShell/releases/download/v7.4.1/PowerShell-7.4.1-win-x86.msi) - needed in case of lack permissions to execute `PowerShell` scripts.

## Obtain qemu package

Obtain package using web-request, and extract it into `Downloads` directory.
```ps
(Invoke-WebRequest -UserAgent "Wget" -Uri https://qemu.weilnetz.de/w64/2023/qemu-w64-setup-20231224.exe -OutFile $env:USERPROFILE'\Downloads\qemu.exe') -and (7z.exe e .\qemu.exe -oqemu)
```

#### optional

Get the package using winget, you will have to adjust the rest of the script accordingly.
```ps
winget install --id=SoftwareFreedomConservancy.QEMU  -e
```

## Create vm disk
```ps
cd "$env:USERPROFILE/Downloads/qemu"
./qemu-img create -f qcow2 ./disk 50G
```
## Create vm

Fetch debian iso.
```ps
Invoke-WebRequest -UserAgent "Wget" -Uri https://gemmei.ftp.acc.umu.se/debian-cd/current/amd64/iso-cd/debian-12.4.0-amd64-netinst.iso -OutFile $env:USERPROFILE'\Downloads\deb-12-net.iso'
```

Create virtual machine.
```ps
cd "$env:USERPROFILE/Downloads"
'./qemu/qemu-system-x86_64 `
    # windows hypervisor acceleration
    -accel whpx,kernel-irqchip=off `
    -m 2048 `
    -boot d `
    -smp 2 `
    -net nic,model=virtio `
    -hda ./qemu/disk `
    -cdrom "./deb-12-net.iso" ^
    # Optionaly usage of UEFI bios
    -bios ./bios64.bin
' | Invoke-Expression  2> $null
```
## Invoke script (all-in one)

I also put my own [scipt](./spinnup) here to skip some restrictions, everything is wrapped in a clean cmd.

## Tips

- Adjust this script to your needs and copy it into [shell:startup](https://support.microsoft.com/en-us/windows/add-an-app-to-run-automatically-at-startup-in-windows-10-150da165-dcd9-7230-517b-cf3c295d89dd) directory.

- Obtain pre-compiled ovmf blobs from [here](https://github.com/BlankOn/ovmf-blobs)
