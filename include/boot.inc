;----------loader---------------

LOADER_BASE_ADDR    equ 0x900
LOADER_START_SECTOR equ 0x2

;------------gdt----------------
DESC_G_4K   equ (1<<23)
DESC_D_32   equ (1<<22)
DESC_L      equ (0<<21)
DESC_AVL    equ (0<<20)
DESC_LIMIT_CODE2    equ (1111b<<16)
DESC_LIMIT_DATA2    equ DESC_LIMIT_CODE2
DESC_LIMIT_VIDEO2   equ (0000b<<16)
DESC_P      equ (1<<15)
DESC_DPL_0  equ (00b<<13)
DESC_DPL_1  equ (01b<<13)
DESC_DPL_2  equ (10b<<13)
DESC_DPL_3  equ (11b<<13)
DESC_S_CODE equ (1<<12)
DESC_S_DATA equ DESC_S_CODE
DESC_S_sys  equ (0<<12)
DESC_TYPE_CODE  equ (1000b<<8)
DESC_TYPE_DATA  equ (0010b<<8)
DESC_CODE_HIGH4 equ (0x00<<24) + DESC_G_4K + DESC_D_32 + DESC_L + DESC_AVL + DESC_LIMIT_CODE2 + DESC_P + DESC_DPL_0 + DESC_S_CODE + DESC_TYPE_CODE + 0x00
DESC_DATA_HIGH4 equ (0x00 << 24) + DESC_G_4K + DESC_D_32 + DESC_L + DESC_AVL + DESC_LIMIT_DATA2 + DESC_P +DESC_DPL_0 + DESC_S_DATA + DESC_TYPE_DATA + 0x00
DESC_VIDEO_HIGH4 equ (0x00 << 24)+ DESC_G_4K +DESC_D_32 + DESC_L + DESC_AVL + DESC_LIMIT_VIDEO2 +DESC_P + DESC_DPL_0 + DESC_S_DATA + DESC_TYPE_DATA + 0x0b

;------------------selector------------

RPL0    equ 00b
RPL1    equ 01b
RPL2    equ 10b
RPL3    equ 11b
TI_GDT  equ 000b
TI_LDT  equ 100b
