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
:: we want to store re-usable assets inside our qemu binary directory

set QEMU_MISC_PATH=%QEMU_BINARY_PATH%/misc

:: create misc directory
if not exist "%QEMU_MISC_PATH%" (
  mkdir "%QEMU_MISC_PATH%"
)

:: FETCHING - ISO
:: -------------------

SET ISO_PATH=%QEMU_MISC_PATH%/debian-12.4.0-amd64-netinst.iso
SET URL=https://gemmei.ftp.acc.umu.se/debian-cd/current/amd64/iso-cd/debian-12.4.0-amd64-netinst.iso

if not exist "%ISO_PATH%" (
  curl -A "Wget" -o %ISO_PATH% "%URL%"
)

:: FETCHING - BIOS
:: -------------------
:: https://github.com/BlankOn/ovmf-blobs/blob/master/bios64.bin

SET BIOS_PATH=%QEMU_MISC_PATH%/bios64.bin
SET URL=https://raw.githubusercontent.com/BlankOn/ovmf-blobs/c9379b95fc2b1bf3a8ed90de0f60bd4f0a8b258b/bios64.bin

if not exist "%BIOS_PATH%" (
  curl -A "Wget" -o %BIOS_PATH% "%URL%"
)

:: VIRTUAL-MACHINE
:: -------------------

:: use this script file name
set QEMU_DISK_PATH=%QEMU_BINARY_PATH%/disks/%~n0/

:: create disk directory
if not exist "%QEMU_DISK_PATH%" (
  mkdir "%QEMU_DISK_PATH%"
)

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

:: instance
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
