%include "boot.inc"

global put_str
global put_char

[bits 32]
put_char:
    pushad
    mov ax, SELECTOR_VIDEO
    mov gs, ax
;--------從 CRT controller 取得游標位置--------
;高8位
    mov dx, 0x03d4
    mov al, 0x0e
    out dx, al
    mov dx, 0x03d5
    in  al, dx
    mov ah, al
;低8位    
    mov dx, 0x03d4
    mov al, 0x0f
    out dx, al
    mov dx, 0x03d5
    in  al, dx
;取得列印字元
    mov bx, ax
    mov ecx, [esp + 36]
;是否為特殊字元
    cmp cl, 0xd
    jz  is_cr
    cmp cl, 0xa
    jz  is_lf
    cmp cl, 0x8
    jz  is_backspace

    jmp is_printable

is_backspace:
    dec bx      ;倒退一格
    shl bx, 1   ;VGA每個ASCII由一個word表示，所以用乘2尋找

    mov byte [gs:bx], 0x20
    inc bx
    mov byte [gs:bx], 0x07
    shr bx, 1
    jmp set_cursor

is_printable:
    shl bx, 1
    mov [gs:bx], cl
    inc bx
    mov byte [gs:bx], 0x07
    shr bx, 1
    inc bx
    cmp bx, 2000
    jl  set_cursor

is_cr:
is_lf:
;80行 * 25字，所以把餘數拿走就可以得到行首的座標
    xor dx, dx
    mov ax, bx
    mov si, 80
    div si
    sub bx, dx
    add bx, 80
    cmp bx, 2000
    jl  set_cursor

roll_screen:
;把下面的字往上搬
    cld
    mov ecx, 960
    mov esi, 0xc00b80a0
    mov edi, 0xc00b8000
    rep movsd
;清空最後一行
    mov ebx, 3840
    mov ecx, 80
    cls:
        mov word [gs:ebx], 0x0720
        add ebx, 2
        loop cls
    mov bx, 1920
set_cursor:
    mov dx, 0x03d4
    mov al, 0x0e
    out dx, al
    mov dx, 0x03d5
    mov al, bh
    out dx, al
    mov dx, 0x03d4
    mov al, 0x0f
    out dx, al
    mov dx, 0x03d5
    mov al, bl 
    out dx, al
    
put_char_end:
    popad
    ret

put_str:
    push ebx
    push ecx
    xor ecx, ecx
    mov ebx, [esp + 12]
next_char_in_str:
    mov cl, [ebx]
    cmp cl, 0
    jz  str_terminal
    push ecx
    call put_char
    add esp, 4
    inc ebx
    jmp next_char_in_str
str_terminal:
    pop ecx
    pop ebx
    ret