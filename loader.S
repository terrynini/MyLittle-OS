%include "boot.inc"

LOADER_STACK_TOP equ LOADER_BASE_ADDR
PAGE_DIR_TABLE_POS  equ 0x100000

section loader vstart=LOADER_BASE_ADDR
    mov sp,LOADER_BASE_ADDR
    mov bp,loadermsg
    mov cx,17
    mov ax,0x1301
    mov bx,0x001f
    mov dx,0x1800
    int 0x10
;------e820 get memory size
    xor ebx,ebx
    mov edx,0x534d4150
    mov di,ards_buf
    e820_mem_get_loop:
        mov eax,0x0000e820
        mov ecx,20
        int 0x15
        jc  e820_failed_go_e801
    
        add di,cx
        inc word [ards_nr]
        cmp ebx,0
        jnz e820_mem_get_loop

    mov cx,[ards_nr]
    mov ebx,ards_buf
    xor edx,edx
    find_max_mem_area:
        mov eax,[ebx]
        add eax,[ebx+8]
        add ebx,20
        cmp edx,eax
        jge next_ards
        mov edx,eax
    next_ards:
        loop find_max_mem_area
        jmp  mem_get_ok
;------e801 get memory size-----
e820_failed_go_e801:
    mov ax,0xe801
    int 0x15
    jc  e801_failed_go_88        
    ;below 15MB        
    mov cx,0x400
    mul cx
    shl edx,16
    and eax,0x0000ffff
    or edx,eax
    add edx,0x100000
    mov esi,edx
    ;above 16MB
    xor eax,eax
    mov ax,bx
    mov ecx,0x10000
    mul ecx

    add esi,eax
    mov edx,esi
    jmp mem_get_ok
;-----0x88 get memory size-------
e801_failed_go_88:
    mov ah,0x99
    int 0x15
    jc error_hlt
    and eax,0x0000ffff

    mov cx,0x400
    mul cx
    shl edx,16
    or  edx,eax
    add edx,0x100000

    mem_get_ok:
        mov [total_mem_bytes],edx
;-----protect mode-----------
;1. enable A20
;2. load gdt
;3. set pe in cr0

;==1
    in  al,0x92
    or  al,0000_0010b
    out 0x92,al
;==2
    lgdt    [gdt_ptr]
;==3
    mov eax,cr0
    or  eax,1
    mov cr0,eax

    jmp dword SELECTOR_CODE:p_mode_start

[BITS 32]
p_mode_start:
    mov ax,SELECTOR_DATA
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov esp,LOADER_STACK_TOP
    mov ax,SELECTOR_VIDEO
    mov gs,ax

    mov byte [gs:160],'P'
error_hlt:
jmp $

;==setup PDE PTE ==
setup_page:
    mov ecx, 4096
    mov esi,0
    clear_page_dir:
        mov byte [PAGE_DIR_TABLE_POS + esi], 0
        inc esi
        loop clear_page_dir
create_pde:
    mov eax,PAGE_DIR_TABLE_POS
    add eax,0x1000
    mov ebx,eax
;--------------------------------------------------

GDT_BASE:   
    dd 0x00000000
    dd 0x00000000

GDT_DESC:        
    dd 0x0000ffff
    dd DESC_CODE_HIGH4

DATA_STACK_DESC:    
    dd  0x0000ffff
    dd  DESC_DATA_HIGH4

VIDEO_DESC:    
    dd  0x80000007
    dd  DESC_VIDEO_HIGH4

GDT_SIZE    equ  $-GDT_BASE
GDT_LIMIT   equ  GDT_SIZE-1
times   60 dq 0
SELECTOR_CODE   equ (0x0001<<3) + TI_GDT + RPL0
SELECTOR_DATA   equ (0x0002<<3) + TI_GDT + RPL0
SELECTOR_VIDEO  equ (0x0003<<3) + TI_GDT + RPL0

total_mem_bytes equ 0x510 ;dd 0

gdt_ptr:     
    dw  GDT_LIMIT
    dd  GDT_BASE

ards_buf times 200 db 0
ards_nr dw 0

loadermsg: 
    db '2 loader in real.'
