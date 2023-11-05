nasm boot.asm -f bin -o boot.bin
nasm data.asm -f bin -o data.bin
pause
erase os.bin
type boot.bin data.bin >> os.bin
run
cls