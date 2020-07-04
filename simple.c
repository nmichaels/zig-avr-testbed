#include <stdint.h>

void main(void) 
{
    register uint8_t i;
    volatile uint8_t j;
    j = 0;
    for (i = 0; i < 10; i++)
    {
        j++;
    }
}
