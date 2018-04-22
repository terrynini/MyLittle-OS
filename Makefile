all:img


img:asm
	dd if=mbr.bin of=hd60M.img count=1 bs=512 conv=notrunc
	dd if=loader.bin of=hd60M.img bs=512 count=4 seek=1 conv=notrunc 
	dd if=kernel/kernel.bin of=hd60M.img bs=512 count=200 seek=5 conv=notrunc	
asm:
	nasm -I include/ -o mbr.bin mbr.S
	nasm -I include/ -o loader.bin loader.S
	gcc -c -o kernel/main.o kernel/main.c && ld kernel/main.o -Ttext 0xc0001000 -o kernel/main.bin
	objcopy -O binary -j .text kernel/main.bin kernel/kernel.bin
clean:
	rm *.bin
	rm kernel/*.bin
