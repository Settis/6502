#!/bin/env python3
import textwrap

class ForthWord:
    def __init__(self, name: str):
        self.name = name
        self.lines = []
        self.immediate = False
        self.hide = False
        self.ended = False

    def add_line(self, line: str):
        if line == ';':
            self.ended = True
            return
        for word in line.split('\\')[0].split(' '):
            if word:
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
    
def print_name(name: str) -> str:
    return (name.replace('!', 'EXCL')
        .replace('@', 'AT')
        .replace('>', 'GT')
        .replace('+', 'PLUS')
        .replace('*', 'MUL')
        .replace('=', 'EQ'))

class Program:
    def __init__(self):
        self.words = []
        self.current_word = None

    def add_line(self, line: str):
        if line.strip() == '':
            return
        
        if self.current_word:
            self.current_word.add_line(line)
            if self.current_word.ended:
                self.current_word = None
            return
        
        if line.startswith(': '):
            name = line.split(' ')[1]
            word = ForthWord(name)
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

    def get_header(self, word: AsmWord | ForthWord) -> str:
        flags = '$80'
        if word.immediate:
            flags += ' | $40'
        return textwrap.dedent(f"""\
            FORTH_WORD_{print_name(word.name)}_H:
                .byte {flags} | .strlen("{word.name}")
                .byte "{word.name}\"""")

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
