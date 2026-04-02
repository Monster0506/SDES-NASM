# S-DES

## Requirements

- 64-bit Linux
- `nasm`
- `gcc`

## Build

```
nasm -f elf64 -o main.o main.asm
nasm -f elf64 -o io.o io.asm
nasm -f elf64 -o sdes_utils.o sdes_utils.asm
nasm -f elf64 -o sdes_keys.o sdes_keys.asm
nasm -f elf64 -o sdes_cipher.o sdes_cipher.asm
gcc -no-pie -o sdes main.o io.o sdes_utils.o sdes_keys.o sdes_cipher.o
```

## Run

```
./sdes
```

The program will prompt for a plaintext string and a 10-bit key (e.g. `1111111111`), print the ciphertext in hex, then ask you to guess the key.
