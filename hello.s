_start:
forever:
    ebreak
    wfi
    j forever

hello:
    .ascii "Hello, World!\n"
    .fill 510 - (. - _start), 1, 0
    .short 0xAA55