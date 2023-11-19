# Bootloader that prints bad apple

- https://archive.org/details/bad_apple_is.7z
- format frames using python code

### HOW TO RUN
##### Make
''' nasm -f bin boot.asm -o os.bin '''
##### RUN
''' qemu-system-x86_64 os.bin '''

### TO DO
- get the entire video working
