from dataclasses import dataclass
from typing import List
from xml.dom.minidom import Element
import xml.etree.ElementTree as ET

@dataclass
class Pitch:
    step: str
    octave: int
    alter: int = 0

@dataclass
class Note:
    type: str
    pitch: Pitch = None
    rest: bool = False
    dot: int = 0
    duration: int = None

@dataclass
class Timing:
    beats: int
    beat_type: int
    beat_unit: str = None
    per_minute: int = None
    divisions: int = None

@dataclass
class Measure:
    number: int
    notes: List[Note]
    timing: Timing = None
    percussion: bool = False

@dataclass
class Part:
    id: str
    measures: List[Measure]

@dataclass
class Music:
    parts: List[Part]

def read(file_name: str) -> Music:
    tree = ET.parse(file_name)
    root = tree.getroot()
    return Music([read_part(part) for part in root.findall('part')])

def read_part(part: Element) -> Part:
    return Part(part.get('id'), [read_measure(measure) for measure in part.findall('measure')])

def read_measure(measure_element: Element) -> Measure:
    measure = Measure(int(measure_element.get('number')), [])
    for element in measure_element:
        if element.tag == 'attributes':
            time = element.find('time')
            measure.timing = Timing(int(time.find('beats').text), int(time.find('beat-type').text))
            measure.timing.divisions = int(element.find('divisions').text)
            if element.find('clef').find('sign').text == 'percussion':
                measure.percussion = True
        if element.tag == 'direction':
            metronome = element.find('direction-type').find('metronome')
            measure.timing.beat_unit = metronome.find('beat-unit').text
            measure.timing.per_minute = int(metronome.find('per-minute').text)
        if element.tag == 'note':
            measure.notes.append(read_note(element))
        if element.tag == 'backup':
            break
    return measure

def read_note(note_elem: Element) -> Note:
    note = Note(note_elem.find('type').text)
    if note_elem.find('pitch') != None:
        note.pitch = read_pitch(note_elem.find('pitch'))
    note.dot = len(note_elem.findall('dot'))
    if note_elem.find('rest') != None:
        note.rest = True
    note.duration = int(note_elem.find('duration').text)
    return note

def read_pitch(pitch: Element) -> Pitch:
    pitch_result = Pitch(pitch.find('step').text, int(pitch.find('octave').text))
    if pitch.find('alter') != None:
        pitch_result.alter = int(pitch.find('alter').text)
    return pitch_result
