BUILD_DIR = ./build
LIB	= -I include/ -I kernel/ -I lib/
CFLAGS = -fno-builtin -fno-stack-protector -O2 
all:img


img:asm
	dd if=$(BUILD_DIR)/mbr.bin of=hd60M.img count=1 bs=512 conv=notrunc
	dd if=$(BUILD_DIR)/loader.bin of=hd60M.img bs=512 count=4 seek=1 conv=notrunc 
	dd if=$(BUILD_DIR)/kernel.bin of=hd60M.img bs=512 count=200 seek=5 conv=notrunc	
asm:
	nasm  $(LIB) -o $(BUILD_DIR)/mbr.bin mbr.S
	nasm  $(LIB) -o $(BUILD_DIR)/loader.bin loader.S
	nasm  $(LIB) -f elf32 -o $(BUILD_DIR)/print.o lib/print.S
	nasm  $(LIB) -f elf32 -o $(BUILD_DIR)/fill_inter.o kernel/fill_inter.S
	gcc   $(LIB) -m32 -c $(CFLAGS) -o $(BUILD_DIR)/main.o kernel/main.c
	gcc   $(LIB) -m32 -c $(CFLAGS) -o $(BUILD_DIR)/interrupt.o kernel/interrupt.c
	gcc   $(LIB) -m32 -c $(CFLAGS) -o $(BUILD_DIR)/init.o kernel/init.c
	ld -m elf_i386  -Ttext 0xc0001000 -e main -o $(BUILD_DIR)/main.bin $(BUILD_DIR)/*.o
	objcopy -O binary $(BUILD_DIR)/main.bin $(BUILD_DIR)/kernel.bin
clean:
	rm $(BUILD_DIR)/*.*
	#ld -m elf_i386  -Ttext 0xc0001000 -o $(BUILD_DIR)/main.bin $(BUILD_DIR)/main.o $(BUILD_DIR)/init.o $(BUILD_DIR)/interrupt.o $(BUILD_DIR)/print.o $(BUILD_DIR)/fill_inter.o
