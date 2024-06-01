#!/bin/python

rawDisk = open("rawDisk", "rb");

LOGICAL_SECTOR_SIZE = 512
CLUSTER_SIZE = 8
FAT_REGION_SECTOR = 0x820
PSEUDO_DATA_REGION_SECTOR = 0x7c70
ROOT_DIR_CLUSTER = 2

def get_from_little_endian(byte_array):
    if len(byte_array) == 0:
        return 0
    return byte_array[0] + (get_from_little_endian(byte_array[1:]) << 8)

def get_value(byte_array, start, length):
    return get_from_little_endian(byte_array[start:start+length])

def get_cluster(num):
    rawDisk.seek((num*CLUSTER_SIZE+PSEUDO_DATA_REGION_SECTOR)*LOGICAL_SECTOR_SIZE)
    return rawDisk.read(CLUSTER_SIZE*LOGICAL_SECTOR_SIZE)

def print_directory_entry(entry_data):
    name = entry_data[:8].decode('utf-8').strip()
    ext = entry_data[8:11].decode('utf-8').strip()
    start_cluster = (get_value(entry_data, 0x14, 2) << (8*2)) + get_value(entry_data, 0x1a, 2)
    size = get_value(entry_data, 0x1c, 4)
    print(f"file: {name}.{ext} start: {start_cluster} size: {size}")

def print_directory(cluster):
    for i in range(0, len(cluster), 32):
        entry_data = cluster[i:i+32]
        if entry_data[0] == 0:
            break
        if entry_data[0] == 0xe5:
            continue
        if entry_data[0xB] == 0x0F:
            continue
        print_directory_entry(entry_data)

def get_fat_value(record_number):
    rawDisk.seek(FAT_REGION_SECTOR*LOGICAL_SECTOR_SIZE);
    return get_value(rawDisk.read(LOGICAL_SECTOR_SIZE*10), record_number*4, 4)

print_directory(get_cluster(ROOT_DIR_CLUSTER))
print_directory(get_cluster(7))

print("FILE11.dat FAT: " + str(get_fat_value(20)) + " " + str(get_fat_value(21)))
