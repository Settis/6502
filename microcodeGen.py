#!/usr/bin/python

import yaml

config = {}
with open('microcodeSpec.yaml', 'r') as microspec:
    config = yaml.load(microspec, yaml.FullLoader)

counter_offset = 0
instruction_offset = 0

offset_pointer = 0
for addr in config['address']:
    if addr['type'] == 'counter':
        counter_offset = offset_pointer
    if addr['type'] == 'instruction':
        instruction_offset = offset_pointer
    offset_pointer += addr['size']

wordMap = {}
outBitVal = 1
for name in config['outBits']:
    wordMap[name] = outBitVal
    outBitVal = outBitVal << 1


def convert_step(step):
    result = 0
    for command in step.split('|'):
        result = result | wordMap[command.strip()]
    return result


default_start_steps = list(map(convert_step, config['defaultStartSteps']))
default_end_steps = list(map(convert_step, config['defaultEndSteps']))

table = {}
for command in config['commands']:
    instruction = command['value']
    command_type = command.get('type', 'default')
    steps = default_start_steps[:] if command_type == 'default' else []
    steps.extend(list(map(convert_step, command['steps'])))
    steps.extend(default_end_steps)
    counter = 0
    for step in steps:
        table[(instruction << instruction_offset) + (counter << counter_offset)] = step
        counter += 1

with open('microcode.rom', 'w') as rom:
    rom.write('v2.0 raw\n')
    i = 0
    for command in range(1 << offset_pointer):
        rom.write("%x " % table.get(command, 0))
        i += 1
        if i == 8:
            rom.write('\n')
            i = 0


