#!/usr/bin/python

import yaml


def load_config():
    with open('microcodeSpec.yaml', 'r') as microspec:
        return yaml.load(microspec, yaml.FullLoader)


def convert_step(step, world_map):
    result = 0
    for command in step.split('|'):
        result = result | world_map[command.strip()]
    return result


def convert_steps(steps, world_map):
    return list(map(lambda x: convert_step(x, world_map), steps))


def get_condition_addr(conditions_set, conditions):
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


def gen_table(config):
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

    word_map = {}
    for out_bit in config['outBits']:
        bit_type = out_bit.get('type', 'default')
        if bit_type == 'default':
            word_map[out_bit['name']] = 1 << out_bit['offset']
        if bit_type == 'enum':
            offset = out_bit['offset']
            i = 0
            for value in out_bit['values']:
                word_map[value] = i << offset
                i += 1

    default_start_steps = convert_steps(config['defaultStartSteps'], word_map)
    default_end_steps = convert_steps(config['defaultEndSteps'], word_map)
    prefix_steps = {}
    for prefix_step in config['prefixSteps']:
        prefix_steps[prefix_step['name']] = convert_steps(prefix_step['steps'], word_map)

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
        steps.extend(convert_steps(command['steps'], word_map))
        steps.extend(default_end_steps)

        condition_addr = get_condition_addr(condition, conditions)
        counter = 0
        for step in steps:
            step_addr = (instruction << instruction_offset) + (counter << counter_offset)
            for addr in condition_addr:
                table[step_addr + addr] = step
            counter += 1
    return table, offset_pointer


def write_table(table, offset_pointer):
    with open('microcode.rom', 'w') as rom:
        rom.write('v2.0 raw\n')
        i = 0
        for command in range(1 << offset_pointer):
            rom.write("%x " % table.get(command, 0))
            i += 1
            if i == 8:
                rom.write('\n')
                i = 0


def main():
    table, offset = gen_table(load_config())
    write_table(table, offset)


main()