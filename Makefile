all:img


img:asm
	dd if=mbr.bin of=hd60M.img count=1 bs=512 conv=notrunc
	dd if=loader.bin of=hd60M.img bs=512 count=4 seek=1 conv=notrunc 
	dd if=kernel/kernel.bin of=hd60M.img bs=512 count=200 seek=5 conv=notrunc	
asm:
	nasm -I include/ -o mbr.bin mbr.S
	nasm -I include/ -o loader.bin loader.S
	nasm -I include/ -f elf32 -o lib/print.o lib/print.S
	gcc  -I lib/ -m32 -c -o kernel/main.o kernel/main.c
	ld -m elf_i386  kernel/main.o lib/print.o -Ttext 0xc0001000 -o kernel/main.bin
	objcopy -O binary kernel/main.bin kernel/kernel.bin
clean:
	rm *.bin
	rm kernel/*.bin
	rm kernel/*.o
