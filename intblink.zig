const std = @import("std.zig");
const avr = @import("atmega328p.zig");
const led_pin: u8 = 5;
const loop_ms = 0x0a52;
const one_second = 63974;

fn bit(comptime b: u3) comptime u8 {
    return (1 << b);
}

fn flipLed() void {
    avr.portb.* ^= bit(led_pin);
}

// Timer interrupt
// When this uses callconv(.Interrupt) llvm emits an extra sei
// instruction. The callconv(.Signal) avoids that.
export fn __vector_13() callconv(.Signal) void {
    flipLed();
    avr.tcnt1.* = one_second;
}

export fn main() noreturn {
    avr.ddrb.* = bit(led_pin);
    avr.portb.* = bit(led_pin);
    avr.tcnt1.* = one_second;
    avr.tccr1a.* = 0;
    avr.tccr1b.* = bit(0) | bit(2); // clock select: clkio/1024
    avr.timsk1.* = bit(0); // Interrupt on overflow enable
    avr.sei();
    while (true) {}
}
