#!/bin/env python3
from dataclasses import dataclass
import textwrap
import re
from typing import Set

@dataclass
class ProgramState:
    defined_words: Set[str]
    last_label_number: int

def is_digit(word: str) -> bool:
    return re.match(r'^\d+$', word) or re.match(r'^\$[\da-fA-F]+$', word)

class ForthWord:
    def __init__(self, prog_state: ProgramState, name: str):
        self.prog_state = prog_state
        self.name = name
        self.lines = []
        self.immediate = False
        self.hide = False
        self.ended = False
        self.labels_stack = []
        self.string_literal = False

    def add_line(self, line: str):
        if line == ';':
            if len(self.labels_stack) != 0:
                raise Exception("label stack is not empty")
            self.ended = True
            return

        for word in line.split('\\')[0].split(' '):
            if word:
                self.process_word(word)
            
    def get_next_lablel(self):
        label = self.prog_state.last_label_number + 1
        self.prog_state.last_label_number = label
        return label

    def process_word(self, word):
        if word == '."':
            self.string_literal = True
            executor = print_name('(.")')
            self.lines.append(f"    .word FORTH_WORD_{executor}")
            return

        if self.string_literal:
            literal = word[:-1]
            self.lines.append(f"    .byte .strlen(\"{literal}\")")
            self.lines.append(f"    .byte \"{literal}\"")
            self.string_literal = False
            return

        if word == 'IF':
            label = self.get_next_lablel()
            self.lines.append('    .word FORTH_WORD_0BRANCH')
            self.lines.append(f"    .word FORTH_BRANCH_{label}")
            self.labels_stack.append(label)
            return
        
        if word == 'ELSE':
            old_label = self.labels_stack.pop()
            label = self.get_next_lablel()
            self.lines.append('    .word FORTH_WORD_BRANCH')
            self.lines.append(f"    .word FORTH_BRANCH_{label}")
            self.lines.append(f"FORTH_BRANCH_{old_label}:")
            self.labels_stack.append(label)
            return

        if word == 'THEN':
            label = self.labels_stack.pop()
            self.lines.append(f"FORTH_BRANCH_{label}:")
            return

        if word == 'BEGIN':
            label = self.get_next_lablel()
            self.lines.append(f"FORTH_BRANCH_{label}:")
            self.labels_stack.append(label)
            return

        if word == 'UNTIL':
            label = self.labels_stack.pop()
            self.lines.append('    .word FORTH_WORD_0BRANCH')
            self.lines.append(f"    .word FORTH_BRANCH_{label}")
            return

        if word == 'WHILE':
            label = self.get_next_lablel()
            self.lines.append('    .word FORTH_WORD_0BRANCH')
            self.lines.append(f"    .word FORTH_BRANCH_{label}")
            self.labels_stack.append(label)
            return
        
        if word == 'REPEAT':
            label_first = self.labels_stack.pop()
            label_second = self.labels_stack.pop()
            self.lines.append('    .word FORTH_WORD_BRANCH')
            self.lines.append(f"    .word FORTH_BRANCH_{label_second}")
            self.lines.append(f"FORTH_BRANCH_{label_first}:")
            return
        
        if word == 'AGAIN':
            label = self.labels_stack.pop()
            self.lines.append('    .word FORTH_WORD_BRANCH')
            self.lines.append(f"    .word FORTH_BRANCH_{label}")
            return

        if word == 'DO':
            self.lines.append(f"    .word {print_name('FORTH_WORD_(DO)')}")
            label = self.get_next_lablel()
            self.lines.append(f"    .word FORTH_BRANCH_{label}")
            self.labels_stack.append(label)
            label = self.get_next_lablel()
            self.lines.append(f"FORTH_BRANCH_{label}:")
            self.labels_stack.append(label)
            return

        if word == 'LOOP':
            label = self.labels_stack.pop()
            self.lines.append(f"    .word {print_name('FORTH_WORD_(LOOP)')}")
            self.lines.append(f"    .word FORTH_BRANCH_{label}")
            label = self.labels_stack.pop()
            self.lines.append(f"FORTH_BRANCH_{label}:")
            return

        if is_digit(word) and not word in self.prog_state.defined_words:
            self.lines.append('    .word FORTH_WORD_LIT')
            self.lines.append(f"    .word {word}")
        else:
            self.lines.append(f"    .word FORTH_WORD_{print_name(word)}")

    def get_content(self) -> str:
        output_lines = [f"FORTH_WORD_{print_name(self.name)}:", 
                        '    .word DOCOL']
        output_lines.extend(self.lines)
        output_lines.append('    .word FORTH_WORD_DOSEMICOL')
        return "\n".join(output_lines)

class AsmWord:
    def __init__(self, name: str):
        self.name = name
        self.lines = []
        self.immediate = False
        self.hide = False
        self.ended = False

    def add_line(self, line: str):
        if line == 'END-CODE':
            self.ended = True
            return
        self.lines.append(line)

    def get_content(self) -> str:
        output_lines = [f"FORTH_WORD_{print_name(self.name)}:", 
                        f"    .word FORTH_WORD_{print_name(self.name)}_CODE",
                        f"FORTH_WORD_{print_name(self.name)}_CODE:"]
        output_lines.extend(self.lines)
        if not self.lines[-1].strip().startswith('JMP'):
            output_lines.append('    JMP NEXT')
        return "\n".join(output_lines)

class ConstantWord:
    def __init__(self, line: str):
        values = line.split(' CONSTANT ')
        self.name = values[1]
        self.value = values[0]
        self.immediate = False
        self.hide = False
        self.ended = True

    def get_content(self) -> str:
        output_lines = [f"FORTH_WORD_{print_name(self.name)}:", 
                        '    .word DOCON',
                        f"    .word {self.value}"]
        return "\n".join(output_lines)

def print_name(name: str) -> str:
    return (name.replace('!', 'EXCL')
        .replace('@', 'AT')
        .replace('>', 'GT')
        .replace('+', 'PLUS')
        .replace('-', 'MINUS')
        .replace('*', 'MUL')
        .replace('=', 'EQ')
        .replace('(', 'O_PAR')
        .replace(')', 'C_PAR')
        .replace('[', 'O_SB')
        .replace(']', 'C_SB')
        .replace('.', 'DOT')
        .replace('"', 'QUOTE'))

class Program:
    def __init__(self):
        self.words = []
        self.current_word = None
        self.prog_state = ProgramState(set(), 0)

    def add_line(self, line: str):
        if line.strip() == '':
            return
        
        if self.current_word:
            self.current_word.add_line(line)
            if self.current_word.ended:
                self.prog_state.defined_words.add(self.current_word.name)
                self.current_word = None
            return

        if 'CONSTANT' in line:
            self.words.append(ConstantWord(line))
            return
        
        if line.startswith(': '):
            name = line.split(' ')[1]
            word = ForthWord(self.prog_state, name)
            self.words.append(word)
            self.current_word = word
            return
        
        if line.startswith('CODE '):
            name = line.split(' ')[1]
            word = AsmWord(name)
            self.words.append(word)
            self.current_word = word
            return

        if line == 'HIDE':
            self.words[-1].hide = True
            return
        
        if line == 'IMMEDIATE':
            self.words[-1].immediate = True
            return

        raise Exception(f"Unknown thing: {line}")

    def get_header(self, word: AsmWord | ForthWord | ConstantWord) -> str:
        flags = '$80'
        if word.immediate:
            flags += ' | $40'
        name_string_literal = '"' + word.name.replace('"', '\\\"') + '"'
        return textwrap.dedent(f"""\
            FORTH_WORD_{print_name(word.name)}_H:
                .byte {flags} | .strlen({name_string_literal})
                .byte {name_string_literal}""")

    def print_asm(self) -> str:
        if self.current_word:
            raise Exception("All words should be ended")
        last_word = None
        chunks = []
        for word in self.words:
            if not word.hide:
                chunks.append(self.get_header(word))
                if last_word:
                    chunks.append(f"    .word FORTH_WORD_{print_name(last_word.name)}_H")
                else:
                    chunks.append('    .word 0')
            chunks.append(word.get_content())
            if not word.hide:
                last_word = word
        chunks.append(f"LAST_WORD = FORTH_WORD_{print_name(last_word.name)}_H\n")
        return "\n".join(chunks)

def compile():
    with open('core.4th', 'r') as src:
        asm = compile_lines(src.read())
    
    with open('core.a65', 'w') as asm_file:
        asm_file.write(asm)

def compile_lines(content: str) -> str:
    prog = Program()
    for line in content.splitlines():
        prog.add_line(line)
    return prog.print_asm()

if __name__ == "__main__":
    compile()
