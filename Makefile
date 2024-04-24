ARCH = riscv64-elf
CC = $(ARCH)-gcc
LD = $(ARCH)-ld
OBJCOPY = $(ARCH)-objcopy

all: clean kernel.elf

kernel.elf: kernel.o kernel.lds Makefile
	$(LD) -T kernel.lds --no-warn-rwx-segments -o kernel.elf kernel.o

kernel.o: boot.s
	$(CC)  -c $< -o $@

clean:
	rm -f *.o kernel.o kernel.elf

run: kernel.elf
	qemu-system-riscv64 -machine virt -cpu rv64 -smp 4 -m 128M -nographic -bios none -serial mon:stdio -display none -kernel kernel.elf