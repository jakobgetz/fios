# fios
I follow a [tutorial](https://www.youtube.com/watch?v=9t-SPC7Tczc&list=PLFjM7v6KGMpiH2G-kT781ByCNC_0pKpPN&index=1&t=214s) to build my first operating system

# Compiling bootloader
`riscv64-elf-as boot.s -o boot.o`
`riscv64-elf-ld -T kernel.lds boot.o -o kernel.elf`