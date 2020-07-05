CC=avr-gcc
AS=avr-as
LD=avr-ld
OBJDUMP=avr-objdump
OBJCOPY=avr-objcopy
LPATH=-L/usr/lib/gcc/avr/5.4.0/avr5
LARCH=-mavr5
LIBS=/usr/lib/avr/lib/avr5/crtatmega328p.o -lgcc
DEBUG=-g
OPTIMIZE=-O1
# unused-but-set-variable is for obvious reasons
# int-to-pointer-cast is because I can't get the cast to silence the warning
WARN=-Wall -Wextra -Werror -Wno-main -Wno-unused-but-set-variable -Wno-int-to-pointer-cast
MCU=atmega328p
TARGET=-mmcu=$(MCU)
CFLAGS=$(WARN) $(TARGET) $(OPTIMIZE) -std=gnu99 -mint8
PROGRAM=avrdude
PROGRAM_CFG=/etc/avrdude.conf
PROGRAM_DEV=/dev/ttyACM0
EXECUTABLES=$(basename $(wildcard *.c)) $(basename $(wildcard *.zig))
ALL=$(foreach f, $(EXECUTABLES), $(f).s $(f).dmp $(f).hex)

.PHONY: clean

default: $(ALL)

# :: means terminal.
%.elf:: %.c
	$(CC) $(DEBUG) $(CFLAGS) -o $@ $<

#%.elf:: %.S
#	$(CC) -xassembler-with-cpp $< $(TARGET) -o $@ -nostdlib

%.dmp: %.elf
	$(OBJDUMP) -d -S -l $< > $@

%.s:: %.c
	$(CC) $(CFLAGS) -S $<

%.o:: %.zig
	zig build-obj --strip --release-small -target avr-freestanding-none -mcpu=$(MCU) $<

%.elf: %.o
	$(LD) $(LARCH) -o $@ $(LPATH) $^ $(LIBS)

%.hex: %.elf
	$(OBJCOPY) -O ihex $< $@

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

upload-%.elf: %.elf
	$(PROGRAM) -C$(PROGRAM_CFG) -v -V -patmega328p -carduino -P$(PROGRAM_DEV) -b115200 -D -Uflash:w:$<:e

upload-%.hex: %.hex
	$(PROGRAM) -C$(PROGRAM_CFG) -v -V -patmega328p -carduino -P$(PROGRAM_DEV) -b115200 -D -Uflash:w:$<:i

#%:
#	/bin/false

clean:
	rm -f *.dmp *.s *.hex *.bin *.out *.elf *.o
