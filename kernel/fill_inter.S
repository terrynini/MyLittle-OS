[bits 32]


extern put_str

section .data
    intr_str db "interrupt occur!", 0x0a, 0x0

global intr_entry_table:

intr_entry_table:

%macro VECTOR 1-2

section .text
intr_%1_entry:
    push intr_str
    call put_str
    add esp, 4
    mov al, 0x20
    out 0xa0, al
    out 0x20, al
    %if %0 = 2
        add esp, 4
    %endif    
    iret
section .data
    dd  intr_%1_entry

%endmacro    

%assign i 0 
%rep    7 
    VECTOR i
%assign i i+1 
%endrep

VECTOR 8,1
VECTOR 9

%assign i 10 
%rep    4 
    VECTOR i, 1
%assign i i+1 
%endrep

VECTOR 15
VECTOR 16
VECTOR 17, 1

%assign i 18 
%rep 11 
    VECTOR i
%assign i i+1 
%endrep

VECTOR 30, 1
VECTOR 31
VECTOR 32        