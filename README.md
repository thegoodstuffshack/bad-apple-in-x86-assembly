# Bootloader that prints bad apple

- https://archive.org/details/bad_apple_is.7z
- format frames using python code

### HOW TO RUN IN VM
##### Make
``` nasm -f bin src/boot.asm -o os.bin ```
##### Run
```qemu-system-x86_64 -device ide-hd,drive=dr,cyls=4,heads=16,secs=63 -drive if=none,id=dr,format=raw,file=os.bin```
### HOW TO RUN ON BARE-METAL
- see **bare-metal** branch

### TO DO
- fine-tune pit for proper framerate
- add sound
- add menu
