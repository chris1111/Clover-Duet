[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/chris1111/Clover-Duet/blob/main/LICENSE)
# Clover-Duet
### Credit [Clover Team](https://github.com/CloverHackyColor/CloverBootloader)
- You can boot a 10.6 System up to macOS Tahoe 26
- Clover will be Install in the ESP (EFI System Partition) of the target volume
- Clover for Bios (Legacy) Booting.
- BIOS booting on GPT partition.
boot0af (boot0 Active First) bootloader try to boot the active partition defined in MBR. If there is no active partition, it will try to boot the first EFI/FAT32/HFS partition (defined in the MBR and then the GPT) with a valid PBR signature.
This choice will setup selected HFS/Fat32 partition to be active.

#### The script will allow you two choices, Boot6 or Boot7, and an EFI Generic folder for Legacy configurations will also be installed.
- "Boot6 = Clover EFI 64-bits using SATA to access drives. "
- "Boot7 = Clover EFI 64-bits using Bios Block I/O to access drives. "

Warning: ⚠️ If an EFI folder exists in the EFI partition you have chosen, it will be replaced by the Generic EFI folder.
Therefore, be sure to back up this folder if necessary!

### Usage: ⬇︎
- Git Clone

``` bash
git clone https://github.com/chris1111/Clover-Duet.git
```
Or Download ➤ [Clover-Duet](https://github.com/chris1111/Clover-Duet/archive/refs/heads/main.zip)
- Run from double clic on `Clover Duet.tool`


<img loading="lazy" width="600" alt="ChooseDisk" src="https://github.com/chris1111/Clover-Duet/blob/main/ChooseDisk.png">


