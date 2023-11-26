# Bootloader that prints bad apple

- https://archive.org/details/bad_apple_is.7z
- format frames using python code

### HOW TO RUN IN VM
- see <a href="link">**master**</a> branch
### HOW TO RUN ON BARE-METAL
- requires legacy boot capable computer
- you will need to edit source with start CHS location of partition which can be found using:
```fdisk -x```
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
- fine-tune pit for proper framerate
- fix pit for bare-metal
- add sound
- add menu
