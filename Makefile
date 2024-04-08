ARCH = riscv64-elf
CC = $(ARCH)-gcc
FLAGS = -nostartfiles -g
LD = $(ARCH)-ld
OBJCOPY = $(ARCH)-objcopy

all: clean hello.img

hello.img: hello.elf
	$(OBJCOPY) hello.elf -O binary --only-section=.text hello.img

hello.elf: hello.o linker.ld Makefile
	$(LD) -T linker.ld --no-warn-rwx-segments -o hello.elf hello.o

hello.o: hello.s
	$(CC) $(FLAGS) -c $< -o $@

clean:
	rm -f *.o hello.elf hello.img

run: hello.img
	qemu-system-riscv64 -M virt -bios opensbi -serial stdio -display none -kernel hello.img