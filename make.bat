nasm boot.asm -f bin -o boot.bin
nasm data0.asm -f bin -o data0.bin
nasm data1.asm -f bin -o data1.bin
pause
erase os.bin
type boot.bin data0.bin data1.bin >> os.bin
run
cls