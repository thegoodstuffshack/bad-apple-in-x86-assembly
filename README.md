# Bootloader that prints bad apple
### Audio Branch
```nasm -f bin audio.asm -o test.bin```
```qemu-system-x86_64 -audiodev dsound,id=id -machine pcspk-audiodev=id test.bin```
- https://forum.osdev.org/viewtopic.php?f=1&t=27024
- https://www.gamedev.net/?app=ccs&module=pages&section=pages&folder=/reference&id=101&aid=442
- https://unix.stackexchange.com/questions/353558/playing-arbitrary-pcm-sound-throught-the-pc-speaker
- https://web.archive.org/web/20170317074148/http://www.k9spud.com/digital-to-analog-converters/resistor-pwm
