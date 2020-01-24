#!/usr/bin/python

import yaml

config = {}
with open('microcodeSpec.yaml', 'r') as microspec:
    config = yaml.load(microspec, yaml.FullLoader)

counter_offset = 0
instruction_offset = 0
conditions = []

offset_pointer = 0
for addr in config['address']:
    if addr['type'] == 'counter':
        counter_offset = offset_pointer
    if addr['type'] == 'instruction':
        instruction_offset = offset_pointer
    if addr['type'] == 'condition':
        conditions.append({
            'name': addr['name'],
            'offset': offset_pointer
        })
    offset_pointer += addr.get('size', 1)

wordMap = {}
for out_bit in config['outBits']:
    bit_type = out_bit.get('type', 'default')
    if bit_type == 'default':
        wordMap[out_bit['name']] = 1 << out_bit['offset']
    if bit_type == 'enum':
        offset = out_bit['offset']
        i = 0
        for value in out_bit['values']:
            wordMap[value] = i << offset
            i += 1


def convert_step(step):
    result = 0
    for command in step.split('|'):
        result = result | wordMap[command.strip()]
    return result


def convert_steps(steps):
    return list(map(convert_step, steps))


default_start_steps = convert_steps(config['defaultStartSteps'])
default_end_steps = convert_steps(config['defaultEndSteps'])
prefix_steps = {}
for prefix_step in config['prefixSteps']:
    prefix_steps[prefix_step['name']] = convert_steps(prefix_step['steps'])


def get_condition_addr(conditions_set):
    address = [0]
    for condition in conditions:
        name = condition['name']
        offset = condition['offset']
        if name in conditions_set.keys():
            value = conditions_set[name] << offset
            address = list(map(lambda i: i+value, address))
        else:
            value = 1 << offset
            address.extend(list(map(lambda i: i+value, address)))
    return address


table = {}
for command in config['commands']:
    instruction = command['value']
    command_type = command.get('type', 'default')
    prefix = command.get('prefix', None)
    condition = {}
    for flag_description in command.get('condition', []):
        flag, value = flag_description.split('_')
        condition[flag] = int(value)
    steps = []
    if command_type == 'default':
        steps.extend(default_start_steps)
    if prefix:
        steps.extend(prefix_steps[prefix])
    steps.extend(convert_steps(command['steps']))
    steps.extend(default_end_steps)

    condition_addr = get_condition_addr(condition)
    counter = 0
    for step in steps:
        for addr in condition_addr:
            table[(instruction << instruction_offset) + (counter << counter_offset) + addr] = step
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


