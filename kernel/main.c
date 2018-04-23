#include "print.h"

void _start(){
    put_str("Terry_kernel\ncoox\bl");
    while(1){
        asm("hlt");
    };
}