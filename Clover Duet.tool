#!/bin/bash
PARENTDIR=$(dirname "$0")
cd "$PARENTDIR"
# Copyright (c) 2026 chris1111
# Credit: Clover Team
# Vars
apptitle="Installer Clover Duet"
version="1.0"
find . -name '.DS_Store' -type f -delete

# Install Clover Duet to the Disk.
diskutil list
echo "Make sure the Sip is disabled!"
echo "Enter the EFI disk number to install Clover Duet:"
read -r N

if ! diskutil info disk"${N}" |  grep -q "/dev/disk"; then
  echo Disk "$N" not found
  exit 1
fi

if ! diskutil info disk"${N}"s1 | grep -q -e FAT_32 -e EFI; then
  echo "No FAT32 partition to install"
  exit 1
fi

# Write MBR
sudo fdisk -uy -f ./CloverBootloader/usr/standalone/i386/boot0af /dev/rdisk"${N}" || exit 1
diskutil umount disk"${N}"s1
sudo dd if=/dev/rdisk"${N}" count=1 bs=512 of=newbs
sudo fdisk -f ./newbs -u -y /dev/rdisk"${N}"
sudo dd if=/dev/rdisk"${N}"s1 count=1  of=origbs
sudo cp -v ./CloverBootloader/usr/standalone/i386/boot1f32 newbs
sudo dd if=origbs of=newbs skip=3 seek=3 bs=1 count=87 conv=notrunc
sudo dd if=/dev/random of=newbs skip=496 seek=496 bs=1 count=14 conv=notrunc
sudo dd if=newbs of=/dev/rdisk"${N}"s1
#if [[ "$(sudo diskutil mount disk"${N}"s1)" == *"mounted" ]]
if sudo diskutil mount disk"${N}"s1 | grep -q mounted; then

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

fi

# Menu options
options=("Boot6" "Boot7")

# Function 1
function option1 {
echo "You selected Boot6"
cp -v "./CloverBootloader/usr/standalone/i386/x64/boot6" "$(diskutil info  disk"${N}"s1 |    sed -n 's/.*Mount Point: *//p')/boot"
echo  -e "Installing Generic Legacy EFI\033[33;5;7m Wait. . .\033[0m"
rm -rf "$(diskutil info  disk${N}s1 |  sed -n 's/.*Mount Point: *//p')/EFI"
Sleep 1
cp -Rp ./CloverBootloader/EFI "$(diskutil info  disk${N}s1 |  sed -n 's/.*Mount Point: *//p')"
echo "Installing EFI -> /dev/disk"${N}"s1 "
install_log="$(diskutil info  disk${N}s1 |  sed -n 's/.*Mount Point: *//p')/EFI/Clover_Install_Log.txt"
# ---------------------------------------------
# Creating log file
# ---------------------------------------------
echo "" > "$install_log"
echo "Clover Duet installer log - $( date )" >> "$install_log"
echo "Installer Clover EFI bootloader" >> "$install_log"
echo "======================================================" >> "$install_log"
diskutil list >> "$install_log"
echo "================= Clover Duet boot6 ==================" >> "${install_log}"
echo "======================================================" >> "${install_log}"
echo ⎡Clover Duet boot6 install to /dev/disk"${N}"s1⎤ >> "$install_log"
echo ⎡dd if=/dev/disk"${N}" count=1 bs=512 of=newbs⎤ >> "$install_log"
echo ⎡fdisk -f ./newbs -u -y /dev/disk"${N}"⎤ >> "$install_log"
echo ⎡dd if=/dev/disk"${N}"s1 count=1 of=origbs⎤ >> "$install_log"
echo ⎡cp CloverBootloader/usr/standalone/i386/boot1f32 newbs⎤ >> "$install_log"
echo ⎡dd if=origbs of=newbs skip=3 seek=3 bs=1 count=87 conv=notrunc⎤ >> "$install_log"
echo ⎡dd if=/dev/random of=newbs skip=496 seek=496 bs=1 count=14 conv=notrunc⎤ >> "$install_log"
echo ⎡dd if=newbs of=/dev/disk"${N}"s1⎤ >> "$install_log"
echo "======================================================" >> "${install_log}"
echo "======================================================" >> "${install_log}"
echo "=========== Clover Duet Installation Finish ==========" >> "${install_log}"
echo "======================================================" >> "${install_log}"
p=/tmp/$(uuidgen)/EFI
mkdir -p "${p}" || exit 1
if diskutil info  disk"${N}" |  grep -q FDisk_partition_scheme; then
sudo fdisk -e /dev/rdisk"$N" <<-MAKEACTIVE
p
f 1
w
y
q
MAKEACTIVE
fi
Sleep 1
rm -rf ./origbs
rm -rf ./newbs
echo "Done!"
Open "$(diskutil info  disk"${N}"s1 |  sed -n 's/.*Mount Point: *//p')" 
}

# Function 2
function option2 {
echo "You selected Boot7"
cp -v "./CloverBootloader/usr/standalone/i386/x64/boot7" "$(diskutil info  disk"${N}"s1 |    sed -n 's/.*Mount Point: *//p')/boot"
echo  -e "Installing Generic Legacy EFI\033[33;5;7m Wait. . .\033[0m"
rm -rf "$(diskutil info  disk${N}s1 |  sed -n 's/.*Mount Point: *//p')/EFI"
Sleep 1
cp -Rp ./CloverBootloader/EFI "$(diskutil info  disk${N}s1 |  sed -n 's/.*Mount Point: *//p')"
echo "Installing EFI -> /dev/disk"${N}"s1 "
install_log="$(diskutil info  disk${N}s1 |  sed -n 's/.*Mount Point: *//p')/EFI/Clover_Install_Log.txt"
# ---------------------------------------------
# Creating log file
# ---------------------------------------------
echo "" > "$install_log"
echo "Clover Duet installer log - $( date )" >> "$install_log"
echo "Installer Clover EFI bootloader" >> "$install_log"
echo "======================================================" >> "$install_log"
diskutil list >> "$install_log"
echo "================= Clover Duet boot7 ==================" >> "${install_log}"
echo "======================================================" >> "${install_log}"
echo ⎡Clover Duet boot7 install to /dev/disk"${N}"s1⎤ >> "$install_log"
echo ⎡dd if=/dev/disk"${N}" count=1 bs=512 of=newbs⎤ >> "$install_log"
echo ⎡fdisk -f ./newbs -u -y /dev/disk"${N}"⎤ >> "$install_log"
echo ⎡dd if=/dev/disk"${N}"s1 count=1 of=origbs⎤ >> "$install_log"
echo ⎡cp CloverBootloader/usr/standalone/i386/boot1f32 newbs⎤ >> "$install_log"
echo ⎡dd if=origbs of=newbs skip=3 seek=3 bs=1 count=87 conv=notrunc⎤ >> "$install_log"
echo ⎡dd if=/dev/random of=newbs skip=496 seek=496 bs=1 count=14 conv=notrunc⎤ >> "$install_log"
echo ⎡dd if=newbs of=/dev/disk"${N}"s1⎤ >> "$install_log"
echo "======================================================" >> "${install_log}"
echo "======================================================" >> "${install_log}"
echo "=========== Clover Duet Installation Finish ==========" >> "${install_log}"
echo "======================================================" >> "${install_log}"
p=/tmp/$(uuidgen)/EFI
mkdir -p "${p}" || exit 1
if diskutil info  disk"${N}" |  grep -q FDisk_partition_scheme; then
sudo fdisk -e /dev/rdisk"$N" <<-MAKEACTIVE
p
f 1
w
y
q
MAKEACTIVE
fi
Sleep 1
rm -rf ./origbs
rm -rf ./newbs
echo "Done!"
Open "$(diskutil info  disk"${N}"s1 |  sed -n 's/.*Mount Point: *//p')"     
}

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
