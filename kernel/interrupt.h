#include "stdint.h"
void idt_init();
typedef void* intr_handler;

typedef struct{
    uint16_t    func_offset_low_word;
    uint16_t    selector;
    uint8_t     dcount;
    uint8_t     attribute;
    uint16_t    func_offset_high_word;
} gate_desc;