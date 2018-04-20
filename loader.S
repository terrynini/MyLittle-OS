%include "boot.inc"

LOADER_STACK_TOP equ LOADER_BASE_ADDR
PAGE_DIR_TABLE_POS  equ 0x100000

;--------GDT 相關常數--------
GDT_SIZE    equ  GDT_END-GDT_BASE
GDT_LIMIT   equ  GDT_SIZE-1
;--------選擇子相關常數--------
SELECTOR_CODE   equ (0x0001<<3) + TI_GDT + RPL0
SELECTOR_DATA   equ (0x0002<<3) + TI_GDT + RPL0
SELECTOR_VIDEO  equ (0x0003<<3) + TI_GDT + RPL0
;--------記憶體大小記錄在 0x510--------
total_mem_bytes equ 0x510

section loader vstart=LOADER_BASE_ADDR
;--------列印字串--------
    mov sp, LOADER_BASE_ADDR
    mov bp, loadermsg
    mov cx, 17
    mov ax, 0x1301
    mov bx, 0x001f
    mov dx, 0x1800
    int 0x10

;--------e820 get memory size--------
    xor ebx, ebx
    mov edx, 0x534d4150
    mov di, ards_buf
    e820_mem_get_loop:
        mov eax, 0x0000e820
        mov ecx, 20
        int 0x15
        jc  e820_failed_try_e801
    
        add di, cx
        inc word [ards_nr]
        cmp ebx, 0
        jnz e820_mem_get_loop

    mov cx, [ards_nr]
    mov ebx, ards_buf - 20
    xor edx, edx
    find_max_mem_area:
        add ebx, 20
        mov eax, [ebx+8]
        cmp edx, eax
        jge next_ards
        cmp dword [ebx+16], 1
        jne next_ards
        mov edx, eax
    next_ards:
        loop find_max_mem_area
    jmp  mem_get_ok
;--------e801 get memory size--------
e820_failed_try_e801:
    mov ax, 0xe801
    int 0x15
    jc  e801_failed_go_88        
;below 15MB        
    mov cx, 0x400
    mul cx
    shl edx, 16
    and eax, 0x0000ffff
    or edx, eax
    add edx, 0x100000
    mov esi, edx
;above 16MB
    xor eax, eax
    mov ax, bx
    mov ecx, 0x10000
    mul ecx

    add esi, eax
    mov edx, esi
    jmp mem_get_ok
;--------0x88 get memory size--------
e801_failed_go_88:
    mov ah, 0x99
    int 0x15
    jc error_hlt
    and eax, 0x0000ffff
    mov cx, 0x400
    mul cx
    shl edx, 16
    or  edx, eax
    add edx, 0x100000

;儲存得到的記憶體資訊
mem_get_ok:
    mov [total_mem_bytes], edx

;--------進入保護模式--------
;1. 開啟 A20 位址線
;2. 讀取 Global Descriptor Table
;3. set cr0 暫存器的 pe 位

;==1==
    in  al, 0x92
    or  al, 10b
    out 0x92, al
;==2==
    lgdt    [gdt_ptr]
;==3==
    mov eax, cr0
    or  eax, 1
    mov cr0, eax

;用 far jump 來設定段暫存器，使之為保護模式下的選擇子
;且清空 pipeline，避免執行解碼錯誤的指令(真實模式下 GDTR 只使用低20位，其他位為0，D 位會是0，造成把 32bit 指令解碼為 16bit 指令)
    jmp dword SELECTOR_CODE:p_mode_start

[BITS 32]
;以32位元指令的格式組譯指令

p_mode_start:
;初始化段暫存器
    mov ax, SELECTOR_DATA
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, LOADER_STACK_TOP
    mov ax, SELECTOR_VIDEO
    mov gs, ax
;顯示 P
    mov byte [gs:160], 'P'
error_hlt:
jmp $

;--------啟用分頁機制--------
;1. 設定好 PDE、PTE
;2. 把分頁位址放進控制暫存器 cr3
;3. set cr0 暫存器的 pe 位

;把記憶體清零，等等作為分頁目錄
;setup_page:
;    mov ecx, 4096
;    mov esi, 0
;    clear_page_dir:
;        mov byte [PAGE_DIR_TABLE_POS + esi], 0
;        inc esi
;        loop clear_page_dir
;create_pde:
;    mov eax, PAGE_DIR_TABLE_POS
;    add eax, 0x1000
;    mov ebx, eax
;
;    or eax, PG_US_U | PG_RW_W | PG_P
;    mov [PAGE_DIR_TABLE_POS + 0x0], eax
;    mov [PAGE_DIR_TABLE_POS + 0xc00], eax
;    sub eax, 0x1000
;    mov [PAGE_DIR_TABLE_POS + 4092], eax
;    
;    mov ecx, 256
;    mov esi, 0 

;--------GDT--------
;第0個不可用
GDT_BASE:   
    dd 0x00000000
    dd 0x00000000

;平坦模型下的c s
GDT_DESC:        
    dd 0x0000ffff
    dd DESC_CODE_HIGH4

;平坦模型下的 ds,ss
DATA_STACK_DESC:    
    dd  0x0000ffff
    dd  DESC_DATA_HIGH4

;文字模式顯卡的記憶體位置 0xb8000~0xbffff ,((0xbffff-0xb8000)+1)/4-1 = 7
VIDEO_DESC:    
    dd  0x80000007
    dd  DESC_VIDEO_HIGH4

GDT_END:

gdt_ptr:     
    dw  GDT_LIMIT
    dd  GDT_BASE

;Address Range Descriptor Structure
ards_buf times 200 db 0
ards_nr dw 0

loadermsg: 
    db '2 loader in real.'