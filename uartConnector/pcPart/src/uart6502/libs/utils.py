def convert_word_number_to_bytes(word):
    return bytes([word & 0xFF, (word & 0xFF00) >> 8])


def convert_word_bytes_to_number(bytes_array):
    return bytes_array[0] + bytes_array[1]*0x100


POLY = 0x107


def crc(array):
    result = 0
    for byte in array:
        result ^= byte
        for _ in range(8):
            result <<= 1
            if result & 0x100:
                result ^= POLY
    return result


def construct_chunks(total_size):
    chunks = []
    for _ in range(total_size // 0x0ff):
        chunks.append(0x0ff)
    reminder = total_size % 0x0ff
    if reminder:
        chunks.append(reminder)
    return chunks
