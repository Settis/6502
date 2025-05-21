from datetime import timedelta
from typing import List
from converter.sequence import Event, Tone, Mute, Wait

BASE_FREQ = 1843200


def print_asm(events: List[Event]):
    send_command_events = []
    for event in merge_waits(events):
        if isinstance(event, Tone):
            send_command_events.append(event)
        elif isinstance(event, Mute):
            send_command_events.append(event)
        elif isinstance(event, Wait):
            flush_send_commands(send_command_events)
            send_command_events = []
            print_wait(event)
    flush_send_commands(send_command_events)

def flush_send_commands(events: List[Event]):
    if len(events) == 0:
        return
    byte_lines = []
    for event in events:
        if isinstance(event, Tone):
            byte_lines.extend(get_tone_byte_lines(event))
        elif isinstance(event, Mute):
            byte_lines.append(get_mute_line(event))
    print(f"    .byte SEND_COMMAND + {len(byte_lines)}")
    print("\n".join(byte_lines))

def merge_waits(events: List[Event]) -> List[Event]:
    result = []
    last_wait = None
    for event in events:
        if isinstance(event, Wait):
            if last_wait == None:
                last_wait = event
            else:
                last_wait = Wait(last_wait.duration + event.duration)
        else:
            if last_wait != None:
                result.append(last_wait)
                last_wait = None
            result.append(event)
    return result

def get_tone_byte_lines(tone: Tone):
    lines = get_tone_commands(tone)
    attenuator_channel = format(tone.channel*2+1, '03b')[::-1]
    lines.append(f"    .byte %0000{attenuator_channel}1")
    return lines

def get_tone_commands(tone: Tone):
    if tone.channel == 3:
        return [get_percussion_line()]
    else:
        return get_tone_freq_lines(tone)
    
def get_tone_freq_lines(tone: Tone):
    timer = int(BASE_FREQ/tone.frequency/32)
    timer_bits = format(timer, '010b')[::-1]
    channel_bits = format(tone.channel*2, '03b')[::-1]
    return [f"    .byte %{timer_bits[:4]}{channel_bits}1", f"    .byte %{timer_bits[4:]}00"]

def get_percussion_line():
    return '    .byte %00000111'

def get_mute_line(mute: Mute):
    channel_attenuator_bits = format(mute.channel*2+1, '03b')[::-1]
    return f"    .byte %1111{channel_attenuator_bits}1"

def print_wait(wait: Wait):
    wait_50_ms = int(wait.duration // timedelta(milliseconds=50))
    wait_1_ms = int(( wait.duration % timedelta(milliseconds=50) ) // timedelta(milliseconds=1))
    if wait_50_ms != 0:
        print(f"    .byte WAIT_50_MS + {wait_50_ms}")
    if wait_1_ms != 0:
        print(f"    .byte WAIT_1_MS + {wait_1_ms}")
