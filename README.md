# Bootloader that plays bad apple

- get frames from <https://archive.org/details/bad_apple_is.7z> and format using python code (run main.py)
- preformatted frames are included

## HOW TO RUN IN VM

### Make

``` nasm -f bin src/boot.asm -o os.bin ```

- will take a while to compile as every frame is also compiled

### Run

```qemu-system-x86_64 -device ide-hd,drive=dr,cyls=4,heads=16,secs=63 -drive if=none,id=dr,format=raw,file=os.bin```

- this tends to lag with the current settings

## HOW TO RUN ON BARE-METAL

- requires legacy boot capable computer
- you will need to edit source with start CHS location of partition which can be found using:

```fdisk -x```

- i tested by creating a partition and using dd to copy the .bin
- **WARNING: PARTITION DATA WILL BE OVERWRITTEN**

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
- add sound
