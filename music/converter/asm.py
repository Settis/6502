from datetime import timedelta
from typing import List
from converter.sequence import Event, Tone, Mute, Wait

BASE_FREQ = 1843200


def print_asm(events: List[Event]):
    for event in events:
        if isinstance(event, Tone):
            print_tone(event)
        elif isinstance(event, Mute):
            print_mute(event)
        elif isinstance(event, Wait):
            print_wait(event)

def print_tone(tone: Tone):
    timer = int(BASE_FREQ/tone.frequency/32)
    timer_bits = format(timer, '010b')[::-1]
    channel_bits = format(tone.channel*2, '03b')[::-1]
    print(f"    LDA #%{timer_bits[:4]}{channel_bits}1")
    print('    JSR send')
    print(f"    LDA #%{timer_bits[4:]}00")
    print('    JSR send')
    attenuator_channel = format(tone.channel*2+1, '03b')[::-1]
    print(f"    LDA #%0000{attenuator_channel}1")
    print('    JSR send')

def print_mute(mute: Mute):
    channel_attenuator_bits = format(mute.channel*2+1, '03b')[::-1]
    print(f"    LDA #%1111{channel_attenuator_bits}1")
    print("    JSR send")

def print_wait(wait: Wait):
    wait_50_ms = int(wait.duration // timedelta(milliseconds=50))
    wait_1_ms = int(( wait.duration % timedelta(milliseconds=50) ) // timedelta(milliseconds=1))
    if wait_50_ms != 0:
        print(f"    LDA #{wait_50_ms}")
        print("    JSR wait50msOfA")
    if wait_1_ms != 0:
        print(f"    LDA #{wait_1_ms}")
        print("    JSR wait1msOfA")
