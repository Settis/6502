#!/bin/env python3
import converter.musicxml
import converter.sequence
import converter.asm
import converter.forth
import sys

music = converter.musicxml.read(sys.argv[1])
seq = converter.sequence.Sequencer().convert(music)
# converter.asm.print_asm(seq)
converter.forth.print_forth(seq)
