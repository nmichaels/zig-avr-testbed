pub const ddrb = @intToPtr(*volatile u8, 0x24);
pub const portb = @intToPtr(*volatile u8, 0x25);
pub const tcnt1 = @intToPtr(*volatile u16, 0x84);
pub const tccr1a = @intToPtr(*volatile u8, 0x80);
pub const tccr1b = @intToPtr(*volatile u8, 0x81);
pub const timsk1 = @intToPtr(*volatile u8, 0x6f);

pub fn sei() void {
    asm volatile ("sei"
        :
        :
        : "memory"
    );
}

pub fn cli() void {
    asm volatile ("cli"
        :
        :
        : "memory"
    );
}
