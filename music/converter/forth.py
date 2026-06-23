from typing import List
from datetime import timedelta
from converter.sequence import Event, Tone, Mute, Wait

BASE_FREQ = 1843200


def print_forth(events: List[Event]):
    print(": SONG")
    for event in merge_waits(events):
        if isinstance(event, Tone):
            set_tone(event)
        elif isinstance(event, Mute):
            mute_channel(event)
        elif isinstance(event, Wait):
            wait_for(event)
    print("EXIT ; ")
    print("SONG")

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

def set_tone(tone: Tone):
    timer = int(BASE_FREQ/tone.frequency/32)
    print(f"{tone.channel} {timer} CHFQ")

def mute_channel(mute: Mute):
    print(f"{mute.channel} M_CH")

def wait_for(wait: Wait):
    ms = wait.duration // timedelta(milliseconds=1)
    print(f"{ms} WAIT")
