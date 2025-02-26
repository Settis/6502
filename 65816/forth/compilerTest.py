#!/bin/env python3
import textwrap
import unittest
import compile

class TestWordCompilation(unittest.TestCase):
    def __init__(self, methodName = "runTest"):
        super().__init__(methodName)
        self.maxDiff = None

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

    def test_literal_dec_hex(self):
        self.assertEqual(compile.compile_lines(textwrap.dedent('''\
            : LITERALS
                1234 $56F
            ;
            ''')), textwrap.dedent('''\
            FORTH_WORD_LITERALS_H:
                .byte $80 | .strlen("LITERALS")
                .byte "LITERALS"
                .word 0
            FORTH_WORD_LITERALS:
                .word DOCOL
                .word FORTH_WORD_LIT
                .word 1234
                .word FORTH_WORD_LIT
                .word $56F
                .word FORTH_WORD_DOSEMICOL
            LAST_WORD = FORTH_WORD_LITERALS_H
            '''))

    def test_literal_reusage(self):
        self.assertEqual(compile.compile_lines(textwrap.dedent('''\
            : 1
                1
            ;
            : 3
                1 2 +
            ;
            ''')), textwrap.dedent('''\
            FORTH_WORD_1_H:
                .byte $80 | .strlen("1")
                .byte "1"
                .word 0
            FORTH_WORD_1:
                .word DOCOL
                .word FORTH_WORD_LIT
                .word 1
                .word FORTH_WORD_DOSEMICOL
            FORTH_WORD_3_H:
                .byte $80 | .strlen("3")
                .byte "3"
                .word FORTH_WORD_1_H
            FORTH_WORD_3:
                .word DOCOL
                .word FORTH_WORD_1
                .word FORTH_WORD_LIT
                .word 2
                .word FORTH_WORD_PLUS
                .word FORTH_WORD_DOSEMICOL
            LAST_WORD = FORTH_WORD_3_H
            '''))

    def test_string_literal(self):
        pass

    def test_if(self):
        self.assertEqual(compile.compile_lines(textwrap.dedent('''\
            : IF_TEST
                IF
                    PRE_NESTED
                    IF
                        FIRST
                    ELSE
                        SECOND
                    THEN
                    POST_NESTED
                ELSE
                    THIRD
                    IF
                        FOURTH
                    THEN
                THEN
            ;
            ''')), textwrap.dedent('''\
            FORTH_WORD_IF_TEST_H:
                .byte $80 | .strlen("IF_TEST")
                .byte "IF_TEST"
                .word 0
            FORTH_WORD_IF_TEST:
                .word DOCOL
                .word FORTH_WORD_0BRANCH
                .word FORTH_BRANCH_1
                .word FORTH_WORD_PRE_NESTED
                .word FORTH_WORD_0BRANCH
                .word FORTH_BRANCH_2
                .word FORTH_WORD_FIRST
                .word FORTH_WORD_BRANCH
                .word FORTH_BRANCH_3
            FORTH_BRANCH_2:
                .word FORTH_WORD_SECOND
            FORTH_BRANCH_3:
                .word FORTH_WORD_POST_NESTED
                .word FORTH_WORD_BRANCH
                .word FORTH_BRANCH_4
            FORTH_BRANCH_1:
                .word FORTH_WORD_THIRD
                .word FORTH_WORD_0BRANCH
                .word FORTH_BRANCH_5
                .word FORTH_WORD_FOURTH
            FORTH_BRANCH_5:
            FORTH_BRANCH_4:
                .word FORTH_WORD_DOSEMICOL
            LAST_WORD = FORTH_WORD_IF_TEST_H
            '''))

    def test_begin_until(self):
        self.assertEqual(compile.compile_lines(textwrap.dedent('''\
            : TEST
                A
                BEGIN
                    B
                UNTIL
                C
            ;
            ''')), textwrap.dedent('''\
            FORTH_WORD_TEST_H:
                .byte $80 | .strlen("TEST")
                .byte "TEST"
                .word 0
            FORTH_WORD_TEST:
                .word DOCOL
                .word FORTH_WORD_A
            FORTH_BRANCH_1:
                .word FORTH_WORD_B
                .word FORTH_WORD_0BRANCH
                .word FORTH_BRANCH_1
                .word FORTH_WORD_C
                .word FORTH_WORD_DOSEMICOL
            LAST_WORD = FORTH_WORD_TEST_H
            '''))

    def test_begin_while_repeat(self):
        self.assertEqual(compile.compile_lines(textwrap.dedent('''\
            : TEST
                A
                BEGIN
                    B
                WHILE
                    C
                REPEAT
                D
            ;
            ''')), textwrap.dedent('''\
            FORTH_WORD_TEST_H:
                .byte $80 | .strlen("TEST")
                .byte "TEST"
                .word 0
            FORTH_WORD_TEST:
                .word DOCOL
                .word FORTH_WORD_A
            FORTH_BRANCH_1:
                .word FORTH_WORD_B
                .word FORTH_WORD_0BRANCH
                .word FORTH_BRANCH_2
                .word FORTH_WORD_C
                .word FORTH_WORD_BRANCH
                .word FORTH_BRANCH_1
            FORTH_BRANCH_2:
                .word FORTH_WORD_D
                .word FORTH_WORD_DOSEMICOL
            LAST_WORD = FORTH_WORD_TEST_H
            '''))

    def test_begin_again(self):
        self.assertEqual(compile.compile_lines(textwrap.dedent('''\
            : TEST
                A
                BEGIN
                    B
                AGAIN
                C
            ;
            ''')), textwrap.dedent('''\
            FORTH_WORD_TEST_H:
                .byte $80 | .strlen("TEST")
                .byte "TEST"
                .word 0
            FORTH_WORD_TEST:
                .word DOCOL
                .word FORTH_WORD_A
            FORTH_BRANCH_1:
                .word FORTH_WORD_B
                .word FORTH_WORD_BRANCH
                .word FORTH_BRANCH_1
                .word FORTH_WORD_C
                .word FORTH_WORD_DOSEMICOL
            LAST_WORD = FORTH_WORD_TEST_H
            '''))
    
    def test_do_loop(self):
        self.assertEqual(compile.compile_lines(textwrap.dedent('''\
            : TEST
                A
                DO
                    B
                LOOP
                C
            ;
            ''')), textwrap.dedent('''\
            FORTH_WORD_TEST_H:
                .byte $80 | .strlen("TEST")
                .byte "TEST"
                .word 0
            FORTH_WORD_TEST:
                .word DOCOL
                .word FORTH_WORD_A
                .word FORTH_WORD_O_PARDOC_PAR
                .word FORTH_BRANCH_1
            FORTH_BRANCH_2:
                .word FORTH_WORD_B
                .word FORTH_WORD_O_PARLOOPC_PAR
                .word FORTH_BRANCH_2
            FORTH_BRANCH_1:
                .word FORTH_WORD_C
                .word FORTH_WORD_DOSEMICOL
            LAST_WORD = FORTH_WORD_TEST_H
            '''))

    def test_constant(self):
        self.assertEqual(compile.compile_lines(textwrap.dedent('''\
            56 CONSTANT FOO
            SOME_LABEL CONSTANT BAR
            ''')), textwrap.dedent('''\
            FORTH_WORD_FOO_H:
                .byte $80 | .strlen("FOO")
                .byte "FOO"
                .word 0
            FORTH_WORD_FOO:
                .word DOCON
                .word 56
            FORTH_WORD_BAR_H:
                .byte $80 | .strlen("BAR")
                .byte "BAR"
                .word FORTH_WORD_FOO_H
            FORTH_WORD_BAR:
                .word DOCON
                .word SOME_LABEL
            LAST_WORD = FORTH_WORD_BAR_H
            '''))

if __name__ == '__main__':
    unittest.main()
