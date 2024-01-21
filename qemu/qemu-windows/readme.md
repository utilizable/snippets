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
    -bios ./qemu/edk2-x86_64-code.fd
' | Invoke-Expression  2> $null
```
## Invoke script (all-in one)

```cmd
@echo off
setlocal EnableDelayedExpansion

:: FETCHING - QEMU
:: -------------------

set URL=https://qemu.weilnetz.de/w64/2023/qemu-w64-setup-20231224.exe
set QEMU_DOWNLOAD_PATH=%USERPROFILE%/Downloads/qemu-w64-setup-20231224.exe
set QEMU_BINARY_PATH=%USERPROFILE%/qemu_core

:: fetch iso 
if not exist "%QEMU_DOWNLOAD_PATH%" (
  curl -A "Wget" -o "%QEMU_DOWNLOAD_PATH%" "%URL%"
)
:: unzip iso
if not exist "%QEMU_BINARY_PATH%" (
  7z.exe x "%QEMU_DOWNLOAD_PATH%" -o%QEMU_BINARY_PATH% -y
)

:: MISCS
:: -------------------

set QEMU_MISC_PATH=%QEMU_BINARY_PATH%/misc
:: use this script file name
set QEMU_DISK_PATH=%QEMU_BINARY_PATH%/disks/%~n0/

:: create misc directory
if not exist "%QEMU_MISC_PATH%" (
  mkdir "%QEMU_MISC_PATH%"
)

:: create disk directory
if not exist "%QEMU_DISK_PATH%" (
  mkdir "%QEMU_DISK_PATH%"
)

:: FETCHING - ISO
:: -------------------

SET ISO_PATH=%QEMU_MISC_PATH%/debian-12.4.0-amd64-netinst.iso
SET URL=https://gemmei.ftp.acc.umu.se/debian-cd/current/amd64/iso-cd/debian-12.4.0-amd64-netinst.iso

if not exist "%ISO_PATH%" (
	curl -A "Wget" -o %ISO_PATH% "%URL%"
)

:: --------------------------------------

:: FETCHING - BIOS
:: -------------------
:: https://github.com/BlankOn/ovmf-blobs/blob/master/bios64.bin

SET BIOS_PATH=%QEMU_MISC_PATH%/bios64.bin
SET URL=https://raw.githubusercontent.com/BlankOn/ovmf-blobs/c9379b95fc2b1bf3a8ed90de0f60bd4f0a8b258b/bios64.bin

if not exist "%BIOS_PATH%" (
	curl -A "Wget" -o %BIOS_PATH% "%URL%"
)

:: --------------------------------------

:: VIRTUAL-MACHINE
:: -------------------

:: DISKS
:: -------------------

:: disk - a
:: -------------------
set QEMU_VM_DISK_NAME=disk-a
set QEMU_VM_DISK_SIZE=15G
set QEMU_VM_DISK_A_PATH=%QEMU_DISK_PATH%/%QEMU_VM_DISK_NAME%
if not exist "%QEMU_VM_DISK_A_PATH%" (
  %QEMU_BINARY_PATH%/qemu-img create -f qcow2 %QEMU_VM_DISK_A_PATH% %QEMU_VM_DISK_SIZE%
)
:: disk - b
:: -------------------
set QEMU_VM_DISK_NAME=disk-b
set QEMU_VM_DISK_SIZE=50G
set QEMU_VM_DISK_B_PATH=%QEMU_DISK_PATH%/%QEMU_VM_DISK_NAME%
if not exist "%QEMU_VM_DISK_B_PATH%" (
  %QEMU_BINARY_PATH%/qemu-img create -f qcow2 %QEMU_VM_DISK_B_PATH% %QEMU_VM_DISK_SIZE%
)

:: INSTANCE
:: -------------------

set QEMU_VM_SSH_PORT=8022

SET INVOKE=^
  %QEMU_BINARY_PATH%/qemu-system-x86_64.exe ^
  -accel whpx,kernel-irqchip=off ^
  -m 2048 ^
  -boot d ^
  -smp 2 ^
  -net nic,model=virtio ^
  -hda %QEMU_VM_DISK_A_PATH% ^
  -hdb %QEMU_VM_DISK_B_PATH% ^
  -cdrom %ISO_PATH% ^
  -bios %BIOS_PATH% ^
  -net user,hostfwd=tcp::%QEMU_VM_SSH_PORT%-:22
  
%INVOKE%
```

## Tips

- Adjust this script to your needs and copy it into [shell:startup](https://support.microsoft.com/en-us/windows/add-an-app-to-run-automatically-at-startup-in-windows-10-150da165-dcd9-7230-517b-cf3c295d89dd) directory.

- Obtain pre-compiled ovmf blobs from [here](https://github.com/BlankOn/ovmf-blobs)
