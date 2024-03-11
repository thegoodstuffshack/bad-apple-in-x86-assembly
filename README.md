# Bootloader that plays bad apple

- get frames from <https://archive.org/details/bad_apple_is.7z> and format using python code (run main.py)
- preformatted frames are included

## HOW TO RUN IN VM

### Make

``` nasm -f bin src/boot.asm -o os.bin ```

- will take a while to compile as every frame is also compiled

### Run

```qemu-system-x86_64 -device ide-hd,drive=dr,cyls=4,heads=16,secs=63 -drive if=none,id=dr,format=raw,file=os.bin```

- qemu tends to lag so the fps won't be exact, however is fine on bare-metal

## HOW TO RUN ON BARE-METAL

- requires legacy boot capable computer
- you will need to edit the source code with your partitions start CHS, location of partition which can be found using:

```fdisk -x```

- i tested by creating a partition and using dd to copy the .bin
- **WARNING: PARTITION DATA WILL BE OVERWRITTEN**

```dd if=os.bin of=/dev/PARTITION```

- add grub boot menu option by editing /boot/grub/grub.cfg
- the (DRIVE,PARTITION) can be found through grub command line ```ls``` , e.g. (hd0,msdos2)

```
menuentry 'CHOSEN_NAME' {
  set root=(DRIVE,PARTITION)
  chainloader +1
```

- reboot and select new grub entry

### TO DO
- add sound
