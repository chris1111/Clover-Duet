#!/bin/bash
PARENTDIR=$(dirname "$0")
cd "$PARENTDIR"
# Copyright (c) 2026 chris1111
# Credit: Clover Team
# Vars
apptitle="Installer Clover Duet"
version="1.0"
find . -name '.DS_Store' -type f -delete
diskloader="./CloverBootloader/usr/standalone/i386/boot0af"
partitionloaderfat="./CloverBootloader/usr/standalone/i386/boot1f32"
boot6="./CloverBootloader/usr/standalone/i386/x64/boot6"
boot7="./CloverBootloader/usr/standalone/i386/x64/boot7"
EFIFOLDER="./CloverBootloader/EFI"
rm -rf ./origbs
rm -rf ./newbs

# Validate
if [[ -d "$EFIFOLDER" && -f "$boot6" && -f "$boot7" && -f "$partitionloaderfat" ]]; then
 echo "Boot files is in your path!"
 sleep 1
else
 echo "Boot files are missing in your path!"
 sleep 3
 exit
fi

# Install Clover Duet to the Disk.
diskutil list
echo "Make sure the Sip is disabled!"
echo "Enter the EFI disk number to install Clover Duet
Exemple: -> 3"
read -r N
N="${N#disk}"

if ! diskutil info "disk${N}" >/dev/null 2>&1; then
  echo "Disk disk${N} not found"
  exit 1
fi

if ! diskutil info disk"${N}"s1 | grep -q -e FAT_32 -e EFI; then
  echo "No FAT32 partition to install"
  exit 1
fi

echo " "
echo "You are about to modify:"
diskutil info disk"${N}" | grep -e "Device Identifier" -e "Device / Media Name" -e "Disk Size"
diskutil info disk"${N}"s1 | grep -e "Device Identifier" -e "Partition Type" -e "Volume Name" -e "Disk Size"
echo "This will overwrite:"
echo " - the MBR boot code of /dev/rdisk${N}"
echo " - the boot sector of /dev/disk${N}s1"
echo " - the existing EFI folder on disk${N}s1 (backup saved to ./BackUpEFI)"
if diskutil info disk"${N}" | grep -q GUID_partition_scheme; then
 echo "NOTE: disk${N} is GPT — Disk."
fi

# Write MBR
sudo fdisk -uy -f $diskloader /dev/rdisk"${N}" || exit 1
sudo diskutil umount disk"${N}"s1
sudo dd if=/dev/rdisk"${N}"s1 count=1 bs=512 of=origbs
sudo cp -v $partitionloaderfat newbs
sudo dd if=origbs of=newbs skip=3 seek=3 bs=1 count=87 conv=notrunc
sudo dd if=newbs of=/dev/rdisk"${N}"s1 count=1 bs=512

# Create temp Mount Point
EFIPart="/private/tmp/PartEFI"
mkdir -p "$EFIPart"
sudo umount -f "$EFIPart"
sudo mount -t msdos /dev/disk"${N}"s1 "$EFIPart"

echo " "
echo "Install Clover Duet "
echo " "
echo "Boot6 = Clover EFI 64-bits using SATA to access drives. "
echo "Boot7 = Clover EFI 64-bits using Bios Block I/O to access drives. "
echo "=========================================== "
echo "1) Type 1 for Boot6 "
echo "=========================================== "
echo "2) Type 2 for Boot7 "  
echo "=========================================== "

echo "= = = = = = = = = = = = = = = = = = = = = = = = =  "

# ---------------------------------------------
# Creating log file  ($1 = boot6 or boot7)
# ---------------------------------------------
function write_log {
local install_log="$EFIPart/EFI/Clover_Install_Log.txt"
{
echo ""
echo "Clover Duet installer log - $( date )"
echo "Installer Clover EFI bootloader - $1"
echo "======================================================"
diskutil list
echo "================= Clover Duet $1 =================="
echo "======================================================"
echo "Clover Duet $1 install to /dev/disk"${N}"s1"
echo "Commands used:"
echo "fdisk -uy -f $diskloader /dev/rdisk"${N}""
echo "diskutil umount disk"${N}"s1"
echo "dd if=/dev/rdisk"${N}"s1 count=1 bs=512 of=origbs"
echo "cp -v $partitionloaderfat newbs"
echo "dd if=origbs of=newbs skip=3 seek=3 bs=1 count=87 conv=notrunc"
echo "dd if=newbs of=/dev/rdisk"${N}"s1 count=1 bs=512"
echo "cp $1 -> /dev/rdisk"${N}"s1/boot"
echo "cp EFI -> /dev/rdisk"${N}"s1/EFI"
if [[ -n "$EFI_BACKED_UP" ]]; then
echo "Previous EFI folder backed up to: $EFI_BACKED_UP"
fi
echo "======================================================"
echo "=========== Clover Duet Installation Finish =========="
echo "======================================================"
} > "$install_log"
}

# Function 1
function option1 {
echo "You selected Boot6"
cp -v "$boot6" "$EFIPart/boot"
echo  -e "Installing Generic Legacy EFI\033[33;5;7m Wait. . .\033[0m"
# Backup existing EFI folder to ./BackUpEFI before removing it
EFI_BACKED_UP=""
if [[ -e "$EFIPart/EFI" ]]; then
BACKUPEFI="./BackUpEFI/EFI_disk${N}_$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUPEFI"
cp -Rp "$EFIPart/EFI" "$BACKUPEFI/EFI"
echo "Existing EFI folder backed up to $BACKUPEFI"
rm -rf "$EFIPart/EFI"
EFI_BACKED_UP="$BACKUPEFI"
fi
sleep 1
cp -R "$EFIFOLDER" "$EFIPart"
echo "Installing EFI -> /dev/disk"${N}"s1 "
write_log "boot6"
if diskutil info  disk"${N}" |  grep -q FDisk_partition_scheme; then
sudo fdisk -e /dev/rdisk"$N" <<-MAKEACTIVE
p
f 1
w
y
q
MAKEACTIVE
fi
sleep 1
rm -rf ./origbs
rm -rf ./newbs
echo "Done!"
open "$EFIPart"
}

# Function 2
function option2 {
echo "You selected Boot7"
cp -v "$boot7" "$EFIPart/boot"
echo  -e "Installing Generic Legacy EFI\033[33;5;7m Wait. . .\033[0m"
# Backup existing EFI folder to ./BackUpEFI before removing it
EFI_BACKED_UP=""
if [[ -e "$EFIPart/EFI" ]]; then
BACKUPEFI="./BackUpEFI/EFI_disk${N}_$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUPEFI"
cp -Rp "$EFIPart/EFI" "$BACKUPEFI/EFI"
echo "Existing EFI folder backed up to $BACKUPEFI"
rm -rf "$EFIPart/EFI"
EFI_BACKED_UP="$BACKUPEFI"
fi
sleep 1
cp -R "$EFIFOLDER" "$EFIPart"
echo "Installing EFI -> /dev/disk"${N}"s1 "
write_log "boot7"
if diskutil info  disk"${N}" |  grep -q FDisk_partition_scheme; then
sudo fdisk -e /dev/rdisk"$N" <<-MAKEACTIVE
p
f 1
w
y
q
MAKEACTIVE
fi
sleep 1
rm -rf ./origbs
rm -rf ./newbs
echo "Done!"
open "$EFIPart"     
}

# Menu options
options=("Boot6" "Boot7")

# Display menu
PS3="Please enter your choice: Following by Enter "
select option in "${options[@]}"; do
    case $option in
        "Boot6")
            option1
            break
            ;;
        "Boot7")
            option2
            break
            ;;
        *)
            echo "Invalid option. Try again."
            ;;
    esac
done
