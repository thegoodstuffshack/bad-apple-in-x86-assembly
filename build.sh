#!/bin/bash

# COMPILE source using nasm
nasm boot.asm -f bin -o boot.bin
nasm data0.asm -f bin -o data0.bin
nasm data1.asm -f bin -o data1.bin

# Remove previous binary
rm os.bin

# Combine binaries 
cat boot.bin data0.bin data1.bin >> os.bin
