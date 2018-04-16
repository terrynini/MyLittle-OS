;----------loader---------------

LOADER_BASE_ADDR    equ 0x600
LOADER_START_SECTOR equ 0x1

;------------GDT----------------
G_4K   equ (1<<23)
D_32   equ (1<<22)
L_32   equ (0<<21)
AVL    equ (0<<20)
LIMIT_CODE2    equ (1111b<<16)
LIMIT_DATA2    equ (1111b<<16)
LIMIT_VIDEO2   equ (0000b<<16)
P_set        equ (1<<15)
DPL_0  equ (00b<<13)
DPL_1  equ (01b<<13)
DPL_2  equ (10b<<13)
DPL_3  equ (11b<<13)
S_set equ (1<<12)
S_sys  equ (0<<12)
TYPE_CODE  equ (1000b<<8)
TYPE_DATA  equ (0010b<<8)

;Discriptor
DESC_CODE_HIGH4 equ (0x00<<24) + G_4K + D_32 + L_32 + AVL + LIMIT_CODE2 + P_set + DPL_0 + S_set + TYPE_CODE + 0x00
DESC_DATA_HIGH4 equ (0x00<<24) + G_4K + D_32 + L_32 + AVL + LIMIT_DATA2 + P_set +DPL_0 + S_set + TYPE_DATA + 0x00
DESC_VIDEO_HIGH4 equ (0x00<<24)+ G_4K +D_32 + L_32 + AVL + LIMIT_VIDEO2 +P_set + DPL_0 + S_set + TYPE_DATA + 0x0b

;------------------selector------------
;權限
RPL0    equ 00b
RPL1    equ 01b
RPL2    equ 10b
RPL3    equ 11b
;GDT或LDT
TI_GDT  equ 000b
TI_LDT  equ 100b
