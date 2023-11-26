# Bootloader that prints bad apple

- https://archive.org/details/bad_apple_is.7z
- format frames using python code

### HOW TO RUN IN VM
##### Make
``` nasm -f bin boot.asm -o os.bin ```
##### Run
```qemu-system-x86_64 os.bin ```  
```qemu-system-x86_64 -device ide-hd,drive=dr,cyls=10,heads=16,secs=63 -drive if=none,id=dr,format=raw,file=os.bin```
### HOW TO RUN ON BARE-METAL
- requires legacy boot capable computer
- you will need to edit source with start CHS location of partition
- i tested by creating a partition and using dd to copy the .bin  
```dd if=os.bin of=/dev/PARTITION```
- add grub boot menu option by editing /boot/grub/grub.cfg
```
menuentry 'CHOSEN_NAME' {
  set root=(DRIVE,PARTITION)
  chainloader +1
```
- reboot and select new grub entry

### TO DO
- add sound
- add menu
