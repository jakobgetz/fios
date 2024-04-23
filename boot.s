.option norvc

.section .data
hello:  .ascii "Hello, World!\n\0"
welcome: .ascii "Welcome to fios\n\0" 

.section .text.init
.global _start

_start:
    # all hardware threads start running this simultaneously
    # all threads exept #0 should sleep
    csrr t0, mhartid    # store value of mhartid register into t0 (mhartid holds curent hardware thread id)
    bnez t0, _wait      # if the thread id is not 0 jump to wait
    la a0, hello        # load address to hello world into a0 
    call _write_uart 
    la a0, welcome
    call _write_uart
    call _wait

_write_uart:
    li s1, 0x10000000   # UART output register
    addi s2, a0, 0      # s2 is the mem pointer to the byte to write next to uart
    add s3, s2, a1      # add string addr to string length
loop:
    lb t0, 0(s2)        # load next byte at a0 into t0
     sb t0, 0(s1)        # store byte to uart register
    addi s2, s2, 1      # increase mem pointer 
    j loop              # branch back if data of length a1 has not yet been written
return:
    ret

_wait:
    wfi
    