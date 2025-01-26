.scope CharDisplayCommands
    clearDisplay = %00000001
    returnHome = %00000010
    entryModeSet = %00000100
    .scope entryModeSet
        normal = 0
        shift = %00000001
        increment = %00000010
        decrement = 0
    .endscope
    displayControl = %00001000
    .scope displayControl
        displayOn = %00000100
        cursorOn = %00000010
        blinkOn = %00000001
    .endscope
    shifting = %00010000
    .scope shifting
        displayShift = %00001000
        cursorMove = 0
        right = %00000100
        left = 0
    .endscope
.endscope