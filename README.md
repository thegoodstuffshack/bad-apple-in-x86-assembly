# Bootloader that prints bad apple
### Audio Branch
```nasm -f bin audio.asm -o test.bin```
```qemu-system-x86_64 -audiodev dsound,id=id -machine pcspk-audiodev=id test.bin```