# Bootloader that prints bad apple

- https://archive.org/details/bad_apple_is.7z
- format frames using python code

### HOW TO RUN
##### Make
``` nasm -f bin boot.asm -o os.bin ```
##### Run
``` qemu-system-x86_64 os.bin ```
###### or alternatively run on bare-metal
- requires legacy boot capable computer
- convert .bin to .iso (I used gBurner)
- place .iso in Ventoy and boot from usb
- run in memdisk mode

### TO DO
- get the entire video working
