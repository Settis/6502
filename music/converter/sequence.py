import datetime
from dataclasses import dataclass
from typing import List

from converter.musicxml import Measure, Music, Note, Part, Pitch, Timing

class Event:
    pass

@dataclass
class Tone(Event):
    channel: int
    frequency: float

@dataclass
class Mute(Event):
    channel: int

@dataclass
class Wait(Event):
    duration: datetime.timedelta

note_type = {
    'half': 1/2,
    'quarter': 1/4,
    'eighth': 1/8,
    '16th': 1/16,
    '32nd': 1/32,
    '64th': 1/64
}

steps = {
    'C' : 0,
    'D' : 2,
    'E' : 4,
    'F' : 5,
    'G' : 7,
    'A' : 9,
    'B' : 11
}

def get_freq(pitch: Pitch) -> float:
    C2 = 65.40639133
    step = steps[pitch.step]+pitch.alter
    return C2 * pow(1.0594631, step + (pitch.octave-2)*12)

class Sequencer:
    def __init__(self):
        self.whole_note_length = None
        self.sequence = []

    def convert(self, music: Music) -> List[Event]:
        self.process_part(music.parts[0])
        return self.sequence

    def process_part(self, part: Part):
        for measure in part.measures:
            self.process_measure(measure)

    def process_measure(self, measure: Measure):
        if measure.timing:
            self.calc_note_length(measure.timing)
        for note in measure.notes:
            self.process_note(note)

    def process_note(self, note: Note):
        note_length = self.whole_note_length * note_type[note.type]
        if note.dot:
            note_length *= 1.5
        if note.pitch != None:
            self.sequence.append(Tone(0, get_freq(note.pitch)))
            self.sequence.append(Wait(note_length*7/8))
            self.sequence.append(Mute(0))
            self.sequence.append(Wait(note_length/8))
        if note.rest != None:
            self.sequence.append(Wait(note_length))

    def calc_note_length(self, timing: Timing):
        self.whole_note_length = datetime.timedelta(minutes=1) / (timing.per_minute * note_type[timing.beat_unit])
