.option norvc                                   # disable generation of reduced instructions (reduced instructions are part of `C` extension

.equ UART_ADDR,     0x10000000

.macro push_ra                                  # push return address to stack
    addi    sp,     sp,     -8
    sd      ra,     0(sp)
.endm

.macro pop_ra                                   # pop return address from stack
    ld      ra,     0(sp)
    addi    sp,     sp,     8
.endm

.section .data
_stack:         .skip       1024
_scratchpad:    .skip       1024

welcome:        .ascii      "Welcome to fios\0"
newline:        .ascii      "\n\0"
hart_info:      .ascii      "HART ID: \0"
stack_pointer:  .ascii      "Stack Pointer: \0"
isa:            .ascii      "Information about the ISA:\0"
xlen:           .ascii      "XLEN: \0"
hello:          .ascii      "Hello!\0"

.section .text.init
.global _start

_start:
    csrr    t0,     mhartid                     # move HART ID to temp register
    bnez    t0,     _wait                       # deactivate HART except with id 0

    la      sp,     _stack                      # stack pointer (see linker script for label) This needs to be changed I dont get this yet
    addi    sp,     sp,     1024

    la      a0,     welcome                     # write welcome         
    call    _writeln                            # write welcome

    la      a0,     hart_info                   # write HART ID
    call    _write                              #   |
    la      a0,     _scratchpad                 #   |
    csrr    a1,     mhartid                     #   |
    addi    a2,     zero,   10                  #   |
    call    _uitoa                              #   |
    call    _writeln                            # write HART ID

    la a0, stack_pointer                        # write stack pointer 
    call _write                                 #   |
    la a0, _scratchpad                          #   |
    addi a1, sp, 0                              #   |
    addi a2, zero, 16                           #   |
    call _uitoa                                 #   |
    call _writeln                               # write stack pointer


    la      a0,    isa                          # write ISA information
    call    _writeln                            #   |
    la      a0,     xlen                        #   |
    call    _write                              #   |
    csrr    s0,     misa                        # get misa register
    la      a0,     _scratchpad                 #   |
    srl     a1,     s0,     62                  # most significant 2 bits indicate XLEN
    addi    a2,     zero,   2                   #   |
    call    _uitoa                              #   |
    call    _writeln                            #  write ISA information

    # call    _sanity_check                       # perform sanity check

    call _wait                                  # wait


# check mstatus and check the MPP and MIE bits
# and print them to uart
_sanity_check:
    push_ra
    csrr    t0,     mstatus
    li      t1,     0xC00
    and     t2,     t1,     t0

    


# writes a null terminated buffer to UART and terminates it with \n
# inputs:
#   a0: buffer address
_writeln:
    push_ra
    call    _write                              # write the buffer
    la      a0,     newline                     # newline
    call    _write                              # write the newline
    pop_ra
    ret


# writes a null terminated buffer to UART
# inputs:
#   a0: buffer address 
_write:
    li      t1,     UART_ADDR                   # UART output register address
_write_loop:
    lb      t0,     0(a0)                       # next byte of buffer
    beqz    t0,     return                      # check for null terminator
    sb      t0,     0(t1)                       # write to uart
    addi    a0,     a0,     1                   # increment byte address
    j       _write_loop                         # repeat
return:
    ret


# converts unsigned int to null terminated string  
# inputs:
#   a0: buffer address
#   a1: int to convert
#   a2: base
# outputs:
#   a0: buffer address
_uitoa:
    addi    t0,     a0,     0                   # move buffer address into temporary register
    addi    t1,     a1,     0                   # move int into temporary register
    addi    t2,     t1,     0                   # copy int
    addi    t3,     a2,     0                   # move base into temporary register
    addi    t4,     zero,   0                   # digit count
_uitoa_digit_count:     
    divu    t2,     t2,     t3                  # discard last digit
    addi    t4,     t4,     1                   # increment digit ount
    bnez    t2,     _uitoa_digit_count          # loop if not last digit
    add     t4,     t4,     t0                  # address of next char
    sb      zero,   0(t4)                       # zero terminate buffer
_uitoa_conversion:      
    rem     t5,     t1,     t3                  # get last digit
    divu    t1,     t1,     t3                  # discard last digit
    addi    t6,     zero,   10                  # 10 to t6 
    blt     t5,     t6,     _skip_adjust        # if digit higher then 10 ascii conversion works differently
    addi    t5,     t5,     7                   # adjust ascii conversion (refer to ascii table) 
_skip_adjust:
    addi    t5,     t5,     0x30                # convert digit to ascii
    sb      t5,     -1(t4)                      # write digit to buffer
    addi    t4,     t4,     -1                  # decrement address
    bne     t0,     t4,     _uitoa_conversion   # loop if not last digit
    ret




_print_dbg:
    push_ra
    la      a0,     hello                       # dbg message
    call    _writeln                            # write debug message
    pop_ra
    ret


_wait:
    wfi
    