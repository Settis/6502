#!/bin/python

#rawDisk = open("rawSdDataHead", "rb");
rawDisk = open("rawDisk", "rb");

def getBlock(n):
    rawDisk.seek(n*512)
    return rawDisk.read(512)

first_sector = getBlock(0)

boot_signature = first_sector[0x1fe:0x200]
print("Boot signature (expected 55aa): " + boot_signature.hex())

def chs_to_lba(raw_byte_array):
    n_cyllinders = 1023
    n_heads = 254
    n_sectors = 63

    h = raw_byte_array[0]
    s = raw_byte_array[1] & 0b00111111
    c = ((raw_byte_array[1] & 0b11000000) << 2) + raw_byte_array[2]

    return (c*n_heads + h)*n_sectors + (s - 1)

def lba_raw_to_decimal(raw_byte_array):
    return (((((raw_byte_array[3] << 8) + raw_byte_array[2]) << 8) + raw_byte_array[1]) << 8 ) + raw_byte_array[0]

def print_partition_entry(n):
    print("Partition #" + str(n))
    start = 0x1be+(n-1)*16
    partition_entry_raw = first_sector[start:start+16]
    print("Partition type (expected 0c): " + hex(partition_entry_raw[4]))
    chs_first = partition_entry_raw[1:4]
    print("CHS first: " + chs_first.hex() + " to LBA: " + str(chs_to_lba(chs_first)))
    chs_last = partition_entry_raw[5:8]
    print("CHS last: " + chs_last.hex() + " to LBA: " + str(chs_to_lba(chs_last)))
    lba_first = partition_entry_raw[8:0xC]
    print("LBA first: " + lba_first.hex() + " to dec: " + str(lba_raw_to_decimal(lba_first)))
    lba_last = partition_entry_raw[0xC:0x10]
    print("LBA last: " + lba_last.hex() + " to dec: " + str(lba_raw_to_decimal(lba_last)))
    #print(partition_entry_raw.hex())

print_partition_entry(1)

print("It's FAT starting on block 2048")

def get_from_little_endian(byte_array):
    if len(byte_array) == 0:
        return 0
    return byte_array[0] + (get_from_little_endian(byte_array[1:]) << 8)

def get_value(byte_array, start, length):
    return get_from_little_endian(byte_array[start:start+length])

partition_start_sector = 2048
fat_first_sector = getBlock(partition_start_sector)
bytes_per_logical_sector = get_value(fat_first_sector, 0xB, 2)
print("Bytes per logical sector (expected 512): " + str(bytes_per_logical_sector))
fat_sectors_per_cluster = fat_first_sector[0xD]
print("Logial setctors per cluster: " + str(fat_sectors_per_cluster))
fat_reserved_logical_sectors = get_value(fat_first_sector, 0xE, 2)
print("Reserved logical sectors: " + str(fat_reserved_logical_sectors))
print("Number of FAT's (expected 2): " + str(fat_first_sector[0x10]))
print("Media descriptor (expected F8): " + hex(fat_first_sector[0x15]))
fat_total_logical_sectors = get_value(fat_first_sector, 0x20, 4)
print("Total logical sectors: " + str(fat_total_logical_sectors))
fat_logical_sectors_per_fat = get_value(fat_first_sector, 0x24, 4)
print("Logical sectors per FAT: " + str(fat_logical_sectors_per_fat))
print("Drive description: " + fat_first_sector[0x28:0x28+2].hex())
print("Version: " + fat_first_sector[0x2a:0x2a+2].hex())
fat_cluster_number_of_root_directory = get_value(fat_first_sector, 0x2c, 4)
print("Root dir cluster: " + str(fat_cluster_number_of_root_directory))
fat_fs_information_sector_number = get_value(fat_first_sector, 0x30, 2)
print("FS information sector: " + str(fat_fs_information_sector_number))

fat_fs_information_sector = getBlock(partition_start_sector + fat_fs_information_sector_number)
print("FS info signature (expected RRaA): " + str(fat_fs_information_sector[0:4]))
print("FS info signature (expected rrAa): " + str(fat_fs_information_sector[0x1e4:0x1e4+4]))
print("FS info signature (expected 00 00 55 AA): " + fat_fs_information_sector[0x1fc:0x200].hex())
fat_free_data_clusters = get_value(fat_fs_information_sector, 0x1e8, 4)
print("free custers: " + str(fat_free_data_clusters))
fat_last_allocated_cluster = get_value(fat_fs_information_sector, 0x1ec, 4)
print("last allocated cluster: " + str(fat_last_allocated_cluster))

fat_1_region_sector_number = partition_start_sector + fat_reserved_logical_sectors
fat_2_region_sector_number = fat_1_region_sector_number + fat_logical_sectors_per_fat
data_region_sector_number = fat_2_region_sector_number + fat_logical_sectors_per_fat

def get_block_for_cluster(cluster):
    return getBlock(data_region_sector_number + (cluster - 2)*fat_sectors_per_cluster)

def print_directory_entry(byte_array):
    name = byte_array[:8].decode('utf-8').strip()
    ext = byte_array[8:11].decode('utf-8').strip()
    start_cluster = (get_value(byte_array, 0x14, 2) << (8*2)) + get_value(byte_array, 0x1a, 2)
    size = get_value(byte_array, 0x1c, 4)
    print(f"file: {name}.{ext} start: {start_cluster} size: {size}")
    content = get_block_for_cluster(start_cluster)[:size]
    print(f"  content: {content}")

def print_directory(byte_array):
    deleted = 0
    vfat_name = 0
    for i in range(0, 255, 32):
        entry_data = byte_array[i:i+32]
        if entry_data[0] == 0:
            break
        if entry_data[0] == 0xe5:
            deleted += 1
            continue
        if entry_data[0xB] == 0x0F:
            vfat_name += 1
            continue
        print_directory_entry(entry_data)
    print(f"VFAT names: {vfat_name} deleted: {deleted}")

def get_fat_value(record_number):
    return get_value(getBlock(fat_1_region_sector_number), record_number*4, 4)

print("FAT 0: " + hex(get_fat_value(0)))
print("FAT 1: " + hex(get_fat_value(1)))
print("FAT 2: " + hex(get_fat_value(2)))

print_directory(get_block_for_cluster(fat_cluster_number_of_root_directory))
