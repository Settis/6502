def convert_word_number_to_bytes(word):
    return bytes([word & 0xFF, (word & 0xFF00) >> 8])


def convert_word_bytes_to_number(bytes_array):
    return bytes_array[0] + bytes_array[1]*0x100
