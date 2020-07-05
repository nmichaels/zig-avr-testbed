const std = @import("std.zig");

const ddrb = @intToPtr(*volatile u8, 0x24);
const portb = @intToPtr(*volatile u8, 0x25);
const tcnt1 = @intToPtr(*volatile u16, 0x84);
const tccr1a = @intToPtr(*volatile u8, 0x80);
const tccr1b = @intToPtr(*volatile u8, 0x81);
const timsk1 = @intToPtr(*volatile u8, 0x6f);
const led_pin: u8 = 5;
const loop_ms = 0x0a52;
const one_second = 63974;

fn sei() void {
    asm volatile ("sei");
}

fn bit(comptime b: u3) comptime u8 {
    return (1 << b);
}

fn flipLed() void {
    portb.* ^= bit(led_pin);
}

// Timer interrupt
export fn __vector_13() callconv(.Interrupt) void {
    flipLed();
    tcnt1.* = one_second;
}

export fn main() noreturn {
    ddrb.* = bit(led_pin);
    portb.* = bit(led_pin);
    tcnt1.* = one_second;
    tccr1a.* = 0;
    tccr1b.* = bit(0) | bit(2); // clock select: clkio/1024
    timsk1.* = bit(0); // Interrupt on overflow enable
    sei();
    while (true) {}
}
