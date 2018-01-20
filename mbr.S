%include "boot.inc"
SECTION MBR vstart=0x7c00
    mov ax,cs
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov fs,ax
    mov sp,0x7c00
    mov ax, 0xb800
    mov gs, ax

;clean screen
    mov ax, 0x600
    mov bx, 0x700
    mov cx, 0
    mov dx, 0x184f

    int 0x10
;Put data on vedio RAM
    mov byte [gs:0x00], '1'
    mov byte [gs:0x01], 0xA4 ; A=background green & blinking, 4=red front

    mov byte [gs:0x02], ' '
    mov byte [gs:0x03], 0xA4

    mov byte [gs:0x04], 'M'
    mov byte [gs:0x05], 0xA4

    mov byte [gs:0x06], 'B' 
    mov byte [gs:0x07], 0xA4
    
    mov byte [gs:0x08], 'R' 
    mov byte [gs:0x09], 0xA4

    mov eax,LOADER_START_SECTOR
    mov bx,LOADER_BASE_ADDR
    mov cx,1
    call read_disk

    jmp LOADER_BASE_ADDR

read_disk:
    ;eax:LBA, bx:port address, cx:number of blocks
    ;maintain the origin value
    mov esi,eax
    mov di,cx
;read from disk
    ;set sector count
    mov dx,0x1f2
    mov al,cl
    out dx,al

    mov eax,esi
    ;set LBA low 
    mov dx,0x1f3
    out dx,al
    ;set LBA mid
    mov cl,8
    shr eax,cl
    mov dx,0x1f4
    out dx,al
    ;set LBA high
    shr eax,cl
    mov dx,0x1f5
    out dx,al
    ;set device
    shr eax,cl
    and al,0x0f
    or  al,0xe0
    mov dx,0x1f6
    out dx,al
    ;set command "write"
    mov dx,0x1f7
    mov al,0x20
    out dx,al
    ;check the status of disk
    not_ready:
        nop
        in al,dx
        and al,0x88
        cmp al,0x08
        jnz not_ready
    ;read data
    mov ax,di
    mov dx,256
    mul dx
    mov cx,ax
    mov dx,0x1f0
    go_on_read:
        in ax,dx
        mov [bx],ax
        add bx,2
        loop go_on_read
    ret

    times 510-($-$$) db 0
    db 0x55,0xaa
