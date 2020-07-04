#include <stdint.h>
#include <stdbool.h>
#include <avr/io.h>
#include <avr/interrupt.h>

//#define USE_INTERRUPT
#define GCC

#ifdef GCC
#define MAIN_RETURN void
#else
#define MAIN_RETURN int
#undef ISR
#define ISR(vector) \
    void vector (void) __attribute__ ((interrupt));\
    void vector (void)
#endif

#define LED_PIN 5

#define ONE_SECOND 63974
#define BIT(n) (1 << n)

static void flip_led()
{
    PORTB ^= BIT(LED_PIN);
}

#ifdef USE_INTERRUPT
ISR (TIMER1_OVF_vect)
{
    flip_led();
    TCNT1 = ONE_SECOND;
}
#endif

static __attribute__((unused)) void delay(uint8_t ms)
{
    for (uint8_t i = 0; i < ms; i++)
    {
        for (volatile uint16_t j = 0; j < 0x34b; j++)
            ;
    }
}

MAIN_RETURN main(void) __attribute__((noreturn));
MAIN_RETURN main(void)
{
    DDRB = BIT(LED_PIN);
    PORTB = 0x00;

#ifdef USE_INTERRUPT
    TCNT1 = ONE_SECOND;
    TCCR1A = 0x00;
    TCCR1B = BIT(CS10) | BIT(CS12); // timer, prescale: 1024
    TIMSK1 = BIT(TOIE1); // timer1 overflow interrupt
    sei(); // global interrupt enable
    while (true)
        ;
#else
    while(true)
    {
        delay(100);
        flip_led();
    }
#endif
}
