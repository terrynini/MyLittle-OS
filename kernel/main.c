#include "print.h"

void _start(){
    put_char('T');
    put_char('e');
    put_char('r');
    put_char('r');
    put_char('y');
    put_char('_');
    put_char('k');
    put_char('e');
    put_char('r');
    put_char('n');
    put_char('e');
    put_char('l');
    put_char('\n');
    put_char('c');
    put_char('o');
    put_char('o');
    put_char('x');
    put_char('\b');
    put_char('l');
    while(1){
        asm("hlt");
    };
}