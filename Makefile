all:img


img:asm
	dd if=mbr.bin of=hd60M.img bs=512 count=1 conv=notrunc
	
asm:
	nasm -o mbr.bin mbr.S
