# Zig on AVR

This repo gets a trivial Zig program (blink an LED) working on an
Arduino Uno (atmega328p). There is much hackery.

## Prerequisites

This was built using:

 * Zig master some time between 0.6.0 and 0.7.0
 * avr-libc 1:.0.0.+Atmel3.6.1-2
 * binutils-avr 2.26.20160125+Atmel3.6.2-1+b1
 * gcc-avr 1:5.4.0+Atmel3.6.1-2+b1
 * avrdude 6.3-20171130+svn1429-2+b1

Those are Debian's names for the packages. Other distros may use
different names.

## simple.c

Before trying to get Zig to work, I had to make sure I had a working C
toolchain. This program builds and runs just fine.

## blinker.c

It's actually possible to tell that this one's working, because the
LED blinks. The preprocessor symbol `GCC` is defined if we're building
with avr-gcc, which is a requirement to get this whole thing
working. If it's not defined, clang works. I didn't bother to find the
actual symbol the compiler provides; flip it manually.

This program is a bit more complicated, since it's got a version that
uses an ISR. The Zig version does not know about interrupts.

## atmega328p.zig

A place to put constants and functions that would otherwise live in
avr/io.h and avr/interrupt.h. Zig's translate-c got too confused on
the actual AVR headers, so here we are.

## blink.zig

A tiny Zig program to blink an LED using a delay loop.

## intblink.zig

A Zig version of the ISR version of blinker.c. Same as blink.zig, but
with an interrupt. Weird fact: llvm emits an `sei` instruction at the
start of the ISR.

## Makefile

This contains the actual point of this repo. The `zig` command line
uses Zig's `-femit-asm` switch to spit out avr assembler code. That
gets fed to GCC's `ld`, which is actually what llvm does to "support"
AVR. The linker sets up all the interrupt vectors and puts `main` in
the right place. For the C programs, The linked elf gets passed to
`objcopy` to make an intel ihex file. This last step is entirely
optional, since avrdude actually knows how to upload elf files. The
Zig path doesn't do it.

It also includes the `%.dmp` target, which is essential for knowing
whether the other steps are working correctly, and debugging them when
they're not.
