import datetime
from dataclasses import dataclass
from typing import List

from converter.musicxml import Measure, Music, Note, Part, Pitch, Timing

class Event:
    pass

@dataclass
class Tone(Event):
    track_time: datetime.timedelta
    channel: int
    frequency: float

@dataclass
class Mute(Event):
    track_time: datetime.timedelta
    channel: int

@dataclass
class Wait(Event):
    duration: datetime.timedelta

note_type = {
    'whole': 1,
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
        self.divisions = None
        self.sequence = []
        self.track_time = datetime.timedelta()
        self.channel = 0

    def convert(self, music: Music) -> List[Event]:
        for part in music.parts:
            self.process_part(part)
            self.channel += 1
        return self.with_waits()

    def process_part(self, part: Part):
        self.track_time = datetime.timedelta()
        for measure in part.measures:
            self.process_measure(measure)

    def process_measure(self, measure: Measure):
        if measure.timing:
            self.calc_note_length(measure.timing)
        for note in measure.notes:
            self.process_note(note)

    def process_note(self, note: Note):
        # note_music_length = note_type[note.type]
        # dot_fraction = note_music_length
        # for _ in range(note.dot):
        #     dot_fraction /= 2
        #     note_music_length += dot_fraction
        # note_length = self.whole_note_length * note_music_length

        note_length = note.duration * self.division_time / self.divisions

        if note.pitch != None:
            self.sequence.append(Tone(self.track_time, self.channel, get_freq(note.pitch)))
            self.track_time += note_length*7/8
            self.sequence.append(Mute(self.track_time, self.channel))
            self.track_time += note_length/8
        if note.rest:
            self.track_time += note_length

    def calc_note_length(self, timing: Timing):
        self.whole_note_length = datetime.timedelta(minutes=1) / (timing.per_minute * note_type[timing.beat_unit])
        self.division_time = datetime.timedelta(minutes=1) / timing.per_minute
        self.divisions = timing.divisions

    def with_waits(self):
        mixed = sorted(self.sequence, key=lambda it: it.track_time)
        result = []
        last_time = datetime.timedelta()
        for event in mixed:
            event_time = event.track_time
            if event_time > last_time:
                result.append(Wait(event_time-last_time))
                last_time = event_time
            result.append(event)
        return result
