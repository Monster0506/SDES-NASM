#!/bin/bash

nasm -f elf64 -o main.o main.asm
nasm -f elf64 -o io.o io.asm
nasm -f elf64 -o sdes_utils.o sdes_utils.asm
nasm -f elf64 -o sdes_keys.o sdes_keys.asm
nasm -f elf64 -o sdes_cipher.o sdes_cipher.asm

gcc -no-pie -o sdes main.o io.o sdes_utils.o sdes_keys.o sdes_cipher.o
