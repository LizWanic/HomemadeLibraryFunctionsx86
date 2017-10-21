all:
	nasm -f elf32 start.asm
	nasm -f elf32 lib4.asm
	gcc -g -o assign4 -m32 main.c lib4.o start.o -nostdlib -nodefaultlibs -fno-builtin -nostartfiles

clean:
	rm -f start.o
	rm -f lib4.o
	rm -f assign4 
