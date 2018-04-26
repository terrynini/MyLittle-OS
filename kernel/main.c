#include "print.h"
#include "init.h"

void main(){
    put_str("Terry_kernel\ncoox\bl\n");
    init_all();         //init interrupt table
    asm volatile("sti");
    while(1){
        asm("hlt");
    };
}