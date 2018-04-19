%include "boot.inc"


SECTION MBR vstart=0x7c00  
;clear all register and set stack at 0x7c00 , set gs (not have to) to the address of display card in text mode
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov sp, 0x7c00
    mov ax, 0xb800
    mov gs, ax

;clean screen
    ;AH = function number
    ;AL = num of lines to scroll in (0 = blank entire rectangle)
    ;BH = video arrtribute to be use on blank lines
    ;(CH, CL) = row, clm of lower-right corner to scroll
    ;(DH, DL) = row, clm of upper-left corner to scroll
    ;in VGA, there are 25 lines and each has 80 words, index is begin from 0 , so DH=0x18, DL=0x4f 

    mov ax, 0x600
    mov bx, 0x700
    mov cx, 0
    mov dx, 0x184f

    int 0x10

;Put things on display card
;style of word is 0xA4, A=background green & blinking, 4=red front

    mov byte [gs:0x00], '1'
    mov byte [gs:0x01], 0xA4 

    mov byte [gs:0x02], ' '
    mov byte [gs:0x03], 0xA4

    mov byte [gs:0x04], 'M'
    mov byte [gs:0x05], 0xA4

    mov byte [gs:0x06], 'B' 
    mov byte [gs:0x07], 0xA4
    
    mov byte [gs:0x08], 'R' 
    mov byte [gs:0x09], 0xA4

;read loader from disk to RAM
    mov eax, LOADER_START_SECTOR
    mov bx, LOADER_BASE_ADDR
    mov cx, 4
    call read_disk
;execute loader
    jmp LOADER_BASE_ADDR

read_disk:
;---------------------------------------------
;read loder from disk
;eax:LBA num, bx: data address, cx:number of blocks
;---------------------------------------------
;maintain the origin value
    mov esi, eax
    mov di, cx
;read from disk
;set register for sector count
    mov dx, 0x1f2
    mov al, cl
    out dx, al

    mov eax, esi
;set register for LBA low 
    mov dx, 0x1f3
    out dx, al
;set register for LBA mid
    mov cl, 8
    shr eax, cl
    mov dx, 0x1f4
    out dx, al
;set register for LBA high
    shr eax, cl
    mov dx, 0x1f5
    out dx, al
;set register for device
    shr eax, cl
    and al, 0x0f    ;24~27 bits for lba
    or  al, 0xe0    ;lba mode
    mov dx, 0x1f6
    out dx, al
;set register for command 
    mov dx, 0x1f7
    mov al, 0x20    ;0x20 is read
    out dx, al
;check the status of disk
    not_ready:
        nop
        in al, dx
        and al, 0x88
        cmp al, 0x08
        jnz not_ready

;read data from ATA register 0x1f0
    mov ax, di
    mov dx, 256
    mul dx
    mov cx, ax
    mov dx, 0x1f0
    go_on_read:
        in ax, dx
        mov [bx], ax
        add bx, 2
        loop go_on_read
    ret

;padding the rest space of the sector
    times 510-($-$$) db 0
;magic number
    db 0x55, 0xaa
