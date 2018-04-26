#include "interrupt.h"
#include "stdint.h"
#include "global.h"
#include "print.h"
#include "io.h"

#define IDT_DESC_CNT 0x21
#define PIC_M_CTRL  0x20
#define PIC_M_DATA  0x21
#define PIC_S_CTRL  0xa0
#define PIC_S_DATA  0xa1

extern intr_handler intr_entry_table[IDT_DESC_CNT];

static gate_desc idt[IDT_DESC_CNT];

static void pic_init(){
    outb(PIC_M_CTRL, 0x11);
    outb(PIC_M_DATA, 0x20);
    outb(PIC_M_DATA, 0x04);
    outb(PIC_M_DATA, 0x01);
    
    outb(PIC_S_CTRL, 0x11);
    outb(PIC_S_DATA, 0x28);
    outb(PIC_S_DATA, 0x02);
    outb(PIC_S_DATA, 0x01); 

    outb(PIC_M_DATA, 0xfe);
    outb(PIC_S_DATA, 0xff);

    put_str("    pic_init done\n");
}

static void make_idt_desc(gate_desc* p_gdesc, uint8_t attr, intr_handler function){
    p_gdesc->func_offset_high_word = (uint32_t)function & 0xFFFF0000;
    p_gdesc->attribute = attr;
    p_gdesc->dcount = 0;
    p_gdesc->selector = SELECTOR_K_CODE;
    p_gdesc->func_offset_low_word = (uint32_t)function & 0x0000FFFF;
}

static void idt_desc_init(){
   int i;
   for( i = 0 ; i < IDT_DESC_CNT ; i++){
       make_idt_desc(&idt[i], IDT_DESC_ATTR_DPL0, intr_entry_table[i]);
   }
   put_str("    idt_desc_init done\n"); 
}

void idt_init(){
    put_str("idt_init start\n");
    idt_desc_init();    //init Interrupt Desciptor Table
    pic_init();         //init Progammable Interrupt controller
    uint64_t    idt_register = ((sizeof(idt) - 1) | ((uint64_t)((uint32_t)idt<<16)));
    asm volatile ("lidt %0" :: "m"(idt_register));
    put_str("idt_init done\n");
}