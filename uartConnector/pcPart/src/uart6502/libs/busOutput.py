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
    0x0a: 'ASL',
    0x18: 'CLC',
    0x1a: 'INC',
    0x20: 'JSR _',
    0x29: 'AND #_',
    0x45: 'EOR _',
    0x49: 'EOR #_',
    0x4c: 'JMP _',
    0x5a: 'PHY',
    0x60: 'RTS',
    0x64: 'STZ _',
    0x78: 'SEI',
    0x7a: 'PLY',
    0x80: 'BRA _',
    0x85: 'STA _',
    0x86: 'STX _',
    0x88: 'DEY',
    0x8a: 'TXA',
    0x8d: 'STA _',
    0x90: 'BCC _',
    0x91: 'STA (_),Y',
    0x9a: 'TXS',
    0xa0: 'LDY #_',
    0xa2: 'LDX #_',
    0xa6: 'LDX _',
    0xa9: 'LDA #_',
    0xaa: 'TAX',
    0xad: 'LDA _',
    0xb0: 'BCS _',
    0xc0: 'CPY #_',
    0xc2: 'REP #_',
    0xc4: 'CPY _',
    0xc8: 'INY',
    0xc9: 'CMP #_',
    0xca: 'DEX',
    0xcb: 'WAI',
    0xd0: 'BNE _',
    0xe2: 'SEP #_',
    0xe6: 'INC _',
    0xf0: 'BEQ _',
    0xfb: 'XCE',
    0xfc: 'JSR (_,X)'
}
