all:img


img:asm
	dd if=mbr.bin of=hd60M.img bs=512 count=1 conv=notrunc
	dd if=loader.bin of=hd60M.img bs=512 count=1 seek=1 conv=notrunc
	
asm:
	nasm -I include/ -o mbr.bin mbr.S
	nasm -I include/ -o loader.bin loader.S
