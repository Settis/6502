#!/bin/env python3
import textwrap
import unittest
import compile

class TestWordCompilation(unittest.TestCase):
    def test_word(self):
        self.assertEqual(compile.compile_lines(textwrap.dedent('''\
            : SOME
                FOO BAR
                BAZ
            ;
            ''')), textwrap.dedent('''\
            FORTH_WORD_SOME_H:
                .byte $80 | .strlen("SOME")
                .byte "SOME"
                .word 0
            FORTH_WORD_SOME:
                .word DOCOL
                .word FORTH_WORD_FOO
                .word FORTH_WORD_BAR
                .word FORTH_WORD_BAZ
                .word FORTH_WORD_DOSEMICOL
            LAST_WORD = FORTH_WORD_SOME_H
            '''))

    def test_code(self):
        self.assertEqual(compile.compile_lines(textwrap.dedent('''\
            CODE LL_W
                JSR foo
                LDA BAR
            END-CODE
            ''')), textwrap.dedent('''\
            FORTH_WORD_LL_W_H:
                .byte $80 | .strlen("LL_W")
                .byte "LL_W"
                .word 0
            FORTH_WORD_LL_W:
                .word FORTH_WORD_LL_W_CODE
            FORTH_WORD_LL_W_CODE:
                JSR foo
                LDA BAR
                JMP NEXT
            LAST_WORD = FORTH_WORD_LL_W_H
            '''))
    
    def test_code_ended_with_jmp(self):
        self.assertEqual(compile.compile_lines(textwrap.dedent('''\
            CODE LL_W
                JSR foo
                JMP BAR
            END-CODE
            ''')), textwrap.dedent('''\
            FORTH_WORD_LL_W_H:
                .byte $80 | .strlen("LL_W")
                .byte "LL_W"
                .word 0
            FORTH_WORD_LL_W:
                .word FORTH_WORD_LL_W_CODE
            FORTH_WORD_LL_W_CODE:
                JSR foo
                JMP BAR
            LAST_WORD = FORTH_WORD_LL_W_H
            '''))

    def test_link(self):
        self.assertEqual(compile.compile_lines(textwrap.dedent('''\
            : FIRST 
            ;
            : SECOND
            ;
            ''')), textwrap.dedent('''\
            FORTH_WORD_FIRST_H:
                .byte $80 | .strlen("FIRST")
                .byte "FIRST"
                .word 0
            FORTH_WORD_FIRST:
                .word DOCOL
                .word FORTH_WORD_DOSEMICOL
            FORTH_WORD_SECOND_H:
                .byte $80 | .strlen("SECOND")
                .byte "SECOND"
                .word FORTH_WORD_FIRST_H
            FORTH_WORD_SECOND:
                .word DOCOL
                .word FORTH_WORD_DOSEMICOL
            LAST_WORD = FORTH_WORD_SECOND_H
            '''))

    def test_immediate(self):
        self.assertEqual(compile.compile_lines(textwrap.dedent('''\
            : SOME
                FOO
            ;
            IMMEDIATE
            ''')), textwrap.dedent('''\
            FORTH_WORD_SOME_H:
                .byte $80 | $40 | .strlen("SOME")
                .byte "SOME"
                .word 0
            FORTH_WORD_SOME:
                .word DOCOL
                .word FORTH_WORD_FOO
                .word FORTH_WORD_DOSEMICOL
            LAST_WORD = FORTH_WORD_SOME_H
            '''))

    def test_hide(self):
        self.assertEqual(compile.compile_lines(textwrap.dedent('''\
            : FIRST 
            ;
            : SECOND
            ;
            HIDE
            ''')), textwrap.dedent('''\
            FORTH_WORD_FIRST_H:
                .byte $80 | .strlen("FIRST")
                .byte "FIRST"
                .word 0
            FORTH_WORD_FIRST:
                .word DOCOL
                .word FORTH_WORD_DOSEMICOL
            FORTH_WORD_SECOND:
                .word DOCOL
                .word FORTH_WORD_DOSEMICOL
            LAST_WORD = FORTH_WORD_FIRST_H
            '''))

    def test_comment(self):
        self.assertEqual(compile.compile_lines(textwrap.dedent('''\
            : SOME ( a b -- f )
                FOO \\ the only thing I need
            ;
            ''')), textwrap.dedent('''\
            FORTH_WORD_SOME_H:
                .byte $80 | .strlen("SOME")
                .byte "SOME"
                .word 0
            FORTH_WORD_SOME:
                .word DOCOL
                .word FORTH_WORD_FOO
                .word FORTH_WORD_DOSEMICOL
            LAST_WORD = FORTH_WORD_SOME_H
            '''))

    def test_ignore_empty_line(self):
        self.assertEqual(compile.compile_lines(textwrap.dedent('''\
            : SOME
                FOO

            ;
            
            ''')), textwrap.dedent('''\
            FORTH_WORD_SOME_H:
                .byte $80 | .strlen("SOME")
                .byte "SOME"
                .word 0
            FORTH_WORD_SOME:
                .word DOCOL
                .word FORTH_WORD_FOO
                .word FORTH_WORD_DOSEMICOL
            LAST_WORD = FORTH_WORD_SOME_H
            '''))

    def test_literal_reusage(self):
        pass

    def test_string_literal(self):
        pass

    def test_if(self):
        pass

if __name__ == '__main__':
    unittest.main()
