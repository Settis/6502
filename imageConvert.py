import png
import os

IMAGE_FOLDER = "progs/img/"


def read_image(name):
    data = png.Reader(name).read()
    raw = list(data[2])
    result = []
    for line in raw:
        result_line = []
        for i in range(1, len(line), 2):
            result_line.append(0 if line[i] == 0 else 1)
        result.append(result_line)
    return result


def draw_image(data):
    for line in data:
        print(''.join(map(lambda pix: ' ' if pix == 0 else '*', line)))


def count_pix(data):
    cnt = 0
    for line in data:
        for pix in line:
            if pix == 1:
                cnt += 1
    return cnt


def write_to_code(name, data):
    i = 0
    packs = []
    pixels = []
    for x in range(32):
        if x != 0 and x % 8 == 0:
            packs.append(i)
            i = 0
        for y in range(32):
            if data[x][y] != 0:
                pixels.append(((x << 5) + (31-y)) & 0xff)
                i += 1
    packs.append(i-1)
    print("%s_data:" % name)
    for pack in packs:
        print("\tdc $%02x" % pack)
    for pixel in pixels:
        print("\tdc $%02x" % pixel)


write_to_code("microchip", read_image(IMAGE_FOLDER+"microchip.png"))


# for image_file in os.listdir(IMAGE_FOLDER):
#    data = read_image(IMAGE_FOLDER+"/"+image_file)
#    print("%s has %s pixels" % (image_file, count_pix(data)))

