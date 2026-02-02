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
        result += OPCODE_NAME.get(self.states[0].data, f"{self.states[0].data:02x} ")
        params = []
        data = []
        for i in range(1, len(self.states)):
            state = self.states[i]
            if state.kind == AddrState.PARAM:
                params.insert(0, f"{state.data:02x}")
            else:
                data.append(f"{state.addr:04x}:{state.data:02x} {state.direction}")
        result += "".join(params) + " | " + " ".join(data)
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
    0xe6: 'INC $'
}
