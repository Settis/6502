    INCLUDE "std.asm"

    ORG $0300
debug:
    JMP debug_start
reset:
    JMP reset_start
irq:
