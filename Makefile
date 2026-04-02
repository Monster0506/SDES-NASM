ASM     = nasm
ASMFLAGS = -f elf64
CC      = gcc
CFLAGS  = -no-pie

OBJ = main.o io.o sdes_utils.o sdes_keys.o sdes_cipher.o

sdes: $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^

%.o: %.asm
	$(ASM) $(ASMFLAGS) -o $@ $<

clean:
	rm -f $(OBJ) sdes
