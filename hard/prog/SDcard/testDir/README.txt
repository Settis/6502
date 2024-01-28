There will be several files with different size.

Filenames in lowercase on purpose. This will create a VFAT name for each file, and the file table will not fit into one sector.

file 01 - 0x0000 -    0
file 02 - 0x0001 -    1
file 03 - 0x0010 -   16
// check page border
file 04 - 0x0100 -  256
file 05 - 0x00FF -  255
file 06 - 0x0101 -  257
// check sector border
file 07 - 0x0200 -  512
file 08 - 0x0201 -  513
file 09 - 0x01FF -  511
// check cluster border (8 sectors)
file 10 - 0x1000 - 4096
file 11 - 0x1001 - 4097
file 12 - 0x0FFF - 4065
// check a big file (bigger than 6502 can address)
file 13 - 100Kb
