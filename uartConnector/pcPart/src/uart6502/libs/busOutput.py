from dataclasses import dataclass
from enum import StrEnum

class BusOutput:
    def __init__(self):
        self.states = []

    def register_state(self, state: BusState):
        if state.kind == AddrState.OPCODE:
            self.flush()
        self.states.append(state)

    def flush(self):
        if self.is_full_command():
            self.dump_command()
        else:
            self.dump_raw()
        self.states = []

    def is_full_command(self):
        if len(self.states) == 0 or self.states[0].kind != AddrState.OPCODE:
            return False
        expect_param = True
        for i in range(1, len(self.states)):
            kind = self.states[i].kind
            match kind:
                case AddrState.PARAM:
                    if not expect_param:
                        return False
                case AddrState.DATA:
                    if expect_param:
                        expect_param = False
                case _:
                    return False
        return True

    def dump_raw(self):
        print(" ".join(map(lambda state : f"{state.addr:04x}:{state.data:02x} {state.direction}|{state.kind}", self.states)))

    def dump_command(self):
        result = f"{self.states[0].addr:04x}:"
        result += OPCODE_NAME.get(self.states[0].data, f"${self.states[0].data:02x}")
        params = []
        data = []
        for i in range(1, len(self.states)):
            state = self.states[i]
            if state.kind == AddrState.PARAM:
                params.insert(0, f"{state.data:02x}")
            else:
                data.append(f"{state.addr:04x}:{state.data:02x} {state.direction}")
        if len(params) > 0:
            params_string = "".join(params)
            if '_' in result:
                result = result.replace('_', "$"+params_string)
            else:
                result += " P:" + params_string
        if len(data) > 0:
            result += " | " + " ".join(data)
        print(result)

@dataclass
class BusState:
    data: int
    addr: int
    kind: AddrState
    direction: DataDirection

class DataDirection(StrEnum):
    READ = 'R'
    WRITE = 'W'

def getAddrState(vpa: bool, vda: bool):
    if vpa:
        if vda:
            return AddrState.OPCODE
        else:
            return AddrState.PARAM
    else:
        if vda:
            return AddrState.DATA
        else:
            return AddrState.INTERNAL

class AddrState(StrEnum):
    OPCODE = 'O'
    PARAM = 'P'
    DATA = 'D'
    INTERNAL = 'I'

OPCODE_NAME = {
    0x00: 'BRK _',
    0x06: 'ASL _',
    0x08: 'PHP',
    0x0a: 'ASL',
    0x10: 'BPL _',
    0x18: 'CLC',
    0x1a: 'INC',
    0x20: 'JSR _',
    0x28: 'PLP',
    0x29: 'AND #_',
    0x30: 'BMI _',
    0x32: 'AND (_)',
    0x38: 'SEC',
    0x3a: 'DEC',
    0x40: 'RTI',
    0x45: 'EOR _',
    0x48: 'PHA',
    0x49: 'EOR #_',
    0x4c: 'JMP _',
    0x50: 'BVC _',
    0x54: 'MVN _',
    0x58: 'CLI',
    0x5a: 'PHY',
    0x60: 'RTS',
    0x64: 'STZ _',
    0x65: 'ADC _',
    0x68: 'PLA',
    0x69: 'ADC #_',
    0x6c: 'JMP (_)',
    0x72: 'ADC (_)',
    0x75: 'ADC _,X',
    0x78: 'SEI',
    0x7a: 'PLY',
    0x7c: 'JMP (_,X)',
    0x80: 'BRA _',
    0x83: 'STA _,S',
    0x85: 'STA _',
    0x86: 'STX _',
    0x88: 'DEY',
    0x89: 'BIT #_',
    0x8a: 'TXA',
    0x8c: 'STY _',
    0x8d: 'STA _',
    0x8e: 'STX _',
    0x90: 'BCC _',
    0x91: 'STA (_),Y',
    0x92: 'STA (_)',
    0x95: 'STA _,X',
    0x98: 'TYA',
    0x9a: 'TXS',
    0x9c: 'STZ _',
    0x9d: 'STA _,X',
    0xa0: 'LDY #_',
    0xa2: 'LDX #_',
    0xa3: 'LDA _,S',
    0xa5: 'LDA _',
    0xa6: 'LDX _',
    0xa8: 'TAY',
    0xa9: 'LDA #_',
    0xaa: 'TAX',
    0xad: 'LDA _',
    0xae: 'LDX _',
    0xb0: 'BCS _',
    0xb1: 'LDA (_),Y',
    0xb2: 'LDA (_)',
    0xb5: 'LDA _,X',
    0xbd: 'LDA _,X',
    0xc0: 'CPY #_',
    0xc2: 'REP #_',
    0xc3: 'CMP _,S',
    0xc4: 'CPY _',
    0xc5: 'CMP _',
    0xc8: 'INY',
    0xc9: 'CMP #_',
    0xca: 'DEX',
    0xcb: 'WAI',
    0xd0: 'BNE _',
    0xd1: 'CMP (_),Y',
    0xd2: 'CMP (_)',
    0xda: 'PHX',
    0xe2: 'SEP #_',
    0xe4: 'CPX _',
    0xe6: 'INC _',
    0xe8: 'INX',
    0xe9: 'SBC #_',
    0xf0: 'BEQ _',
    0xf2: 'SBC (_)',
    0xfa: 'PLX',
    0xfb: 'XCE',
    0xfc: 'JSR (_,X)'
}
