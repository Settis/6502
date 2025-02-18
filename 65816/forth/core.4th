CODE EXECUTE ( cfa -- )
    JSR PULL_SP
    TAX
    INC A
    INC A
    STA W
    JMP (0,X)
END-CODE
