const std = @import("std.zig");

const ddrb = @intToPtr(*volatile u8, 0x24);
const portb = @intToPtr(*volatile u8, 0x25);
const led_pin: u8 = 5;
const led_bit: u8 = 1 << led_pin;
const loop_ms = 0x0a52;

fn flipLed() void {
    portb.* ^= led_bit;
}

fn delay(ms: u8) void {
    var count: u8 = 0;
    while (count < ms) : (count += 1) {
        var loop: u16 = 0;
        while (loop < loop_ms) : (loop += 1) {
            asm volatile (""
                :
                :
                : "memory"
            );
        }
    }
}

export fn main() noreturn {
    ddrb.* = led_bit;
    portb.* = led_bit;
    while (true) {
        flipLed();
        delay(100);
    }
}
